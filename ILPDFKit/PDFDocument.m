
#import "PDFDocument.h"
#import "PDFForm.h"
#import "PDFDictionary.h"
#import "PDFArray.h"
#import "PDFStream.h"
#import "PDFPage.h"
#import "PDFUtility.h"
#import "PDFFormButtonField.h"
#import "PDFFormContainer.h"

#import <QuartzCore/QuartzCore.h>

@interface PDFDocument()
    -(NSString*)formIndirectObjectFrom:(NSString*)str WithName:(NSString*)name NewValue:(NSString*)value ObjectNumber:(NSUInteger*)objectNumber GenerationNumber:(NSUInteger*)generationNumber Type:(PDFFormType)type BehindIndex:(NSInteger)index;
    -(NSString*)constructTrailer:(NSString*)file FinalOffset:(NSUInteger)fo;
    -(NSMutableString*)sourceCode;
    -(PDFDictionary*)getTrailer;
    
@end

@implementation PDFDocument

@synthesize documentData;
@synthesize catalog;
@synthesize info;
@synthesize pages;
@synthesize pdfName;
@synthesize forms;
@synthesize documentPath;
@synthesize document;


-(void)dealloc
{
   
    self.documentData = nil;
    self.pdfName = nil;
    [documentPath release];
    [catalog release];
    [info release];
    [pages release];
    [forms release];
    [sourceCode release];
    CGPDFDocumentRelease(document);
    [super dealloc];
}

-(id)initWithData:(NSData *)data
{
    self = [super init];
    if(self != nil)
    {
        document = [PDFUtility createPDFDocumentRefFromData:data];
        documentData = [[NSMutableData alloc] initWithData:data];
    }
    return self;
}

-(id)initWithResource:(NSString *)name
{
    self = [super init];
    if(self != nil)
    {
        if([[[name componentsSeparatedByString:@"."] lastObject] isEqualToString:@"pdf"])
            name = [name substringToIndex:name.length-4];
        document = [PDFUtility createPDFDocumentRefFromResource:name];
        documentPath = [[[NSBundle mainBundle] pathForResource:name ofType:@"pdf"] retain];
    }
    return self;
}

-(id)initWithPath:(NSString*)path
{
    self = [super init];
    if(self != nil)
    {
        document = [PDFUtility createPDFDocumentRefFromPath:path];
        documentPath = [path retain];
    }
    return self;
}


-(BOOL)saveFormsToDocumentData
{
    NSMutableString* retval = [NSMutableString string];
    NSMutableArray* names = [NSMutableArray array];
    for(PDFForm* form in forms)
    {
        if(form.modified == NO)continue;
        if([names containsObject:form.name])continue;
        [names addObject:form.name];
        form.modified = NO;
        NSUInteger objectNumber;
        NSUInteger generationNumber;
        NSString* indirectObject = [self formIndirectObjectFrom:self.sourceCode WithName:form.name NewValue:form.value ObjectNumber:&objectNumber GenerationNumber:&generationNumber Type:form.formType BehindIndex:[self.sourceCode length]];
        NSString* objectNumberString = [NSString stringWithFormat:@"%u",(unsigned int)objectNumber];
        NSString* generationNumberString = [NSString stringWithFormat:@"%05u",(unsigned int)generationNumber];
        NSString* offsetString = [NSString stringWithFormat:@"%010u",(unsigned int)([self.documentData length]+1+[retval length])];
        
        if(indirectObject)
        {
            [retval appendFormat:@"\r%@\rxref\r0 1\r0000000000 65535 f\r\n%@ 1\r%@ %@ n\r\n",indirectObject,objectNumberString,offsetString,generationNumberString];
            NSUInteger finalOffset = [retval rangeOfString:@"xref" options:NSBackwardsSearch].location+[self.documentData length];
            [retval appendString:[self constructTrailer:[self.sourceCode stringByAppendingString:retval] FinalOffset:finalOffset]];
        }
        else return NO;
    }
    
    
    
    [self.documentData appendData:[retval dataUsingEncoding:NSASCIIStringEncoding]];
    return YES;
}

-(void)writeToFile:(NSString*)name
{
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *path = [docsDirectory stringByAppendingPathComponent:name];
    [self.documentData writeToFile:path atomically:YES];
}


-(void)refresh
{
    [catalog release];catalog = nil;
    [pages release];pages = nil;
    [info release];info = nil;
    [sourceCode release];sourceCode = nil;
    CGPDFDocumentRelease(document);document = NULL;
    document = [PDFUtility createPDFDocumentRefFromData:self.documentData];
}



#pragma mark - Getter

-(PDFFormContainer*)forms
{
    if(forms == nil)
    {
        forms = [[PDFFormContainer alloc] initWithParentDocument:self];
    }
    
    return forms;
}


-(NSMutableString*)sourceCode
{
    if(sourceCode == nil)
    {
        sourceCode = [[NSMutableString alloc] initWithData:self.documentData encoding:NSASCIIStringEncoding];
    }
    
    return sourceCode;
}

-(NSMutableData*)documentData
{
    if(documentData == nil)
    {
        documentData = [[NSMutableData alloc] initWithContentsOfFile:documentPath options:NSDataReadingMappedAlways error:NULL];
    }
    
    return documentData;
}

-(PDFDictionary*)catalog
{
    if(catalog == nil)
    {
        catalog = [[PDFDictionary alloc] initWithDictionary:CGPDFDocumentGetCatalog(document)];
    }
    
    return catalog;
}

-(PDFDictionary*)info
{
    if(info == nil)
    {
        info = [[PDFDictionary alloc] initWithDictionary:CGPDFDocumentGetInfo(document)];
    }
    
    return info;
}

-(NSArray*)pages
{
    if(pages == nil)
    {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        
        for(NSUInteger i = 0 ; i < CGPDFDocumentGetNumberOfPages(document); i++)
        {
            PDFPage* add = [[PDFPage alloc] initWithPage:CGPDFDocumentGetPage(document,i+1)];
            [temp addObject:add];
            [add release];
        }
        
        pages = [[NSArray alloc] initWithArray:temp];
        [temp release];
    }
    
    return pages;
}

-(NSUInteger)numberOfPages
{
    return CGPDFDocumentGetNumberOfPages(document);
}

#pragma mark - PDF File Text Utility

-(NSString*)formIndirectObjectFrom:(NSString*)str WithName:(NSString*)name  NewValue:(NSString*)value ObjectNumber:(NSUInteger*)objectNumber GenerationNumber:(NSUInteger*)generationNumber Type:(PDFFormType)type BehindIndex:(NSInteger)index
{
    BOOL simple = ([[name componentsSeparatedByString:@"."] count]==1);
    NSString* search = [NSString stringWithFormat:@"/T(%@)",[[name componentsSeparatedByString:@"."] lastObject]];
    NSUInteger searchLocation = [str rangeOfString:search options:NSBackwardsSearch range:NSMakeRange(0, index)].location;
    
    
    if(searchLocation == NSNotFound)return nil;
    NSUInteger startMarkerLocation = [str rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, searchLocation+1)].location;
    if(startMarkerLocation == NSNotFound)return nil;
    
    NSUInteger startLocation = startMarkerLocation;
    while([str characterAtIndex:startLocation]!='\n' && [str characterAtIndex:startLocation]!='\r')startLocation--;
    
    NSString* objectLine = [str substringWithRange:NSMakeRange(startLocation+1, startMarkerLocation-startLocation)];
    
    NSScanner* scanner = [NSScanner scannerWithString:objectLine];
    [scanner scanInteger:(NSInteger*)objectNumber];
    [scanner scanInteger:(NSInteger*)generationNumber];
    NSString* ret =  [str substringWithRange:NSMakeRange(startLocation+1, [[str substringFromIndex:startLocation+1] rangeOfString:@"endobj"].location+[@"endobj" length])];
    
    if(simple == NO)
    {
        NSString* parentName = @"/Parent";
        NSUInteger objNumber;
        NSUInteger genNumber;
        NSUInteger lastDot = [name rangeOfString:@"." options:NSBackwardsSearch].location;
        [self formIndirectObjectFrom:str WithName:[name substringToIndex:lastDot]  NewValue:(id)[NSNull null] ObjectNumber:&objNumber GenerationNumber:&genNumber Type:type BehindIndex:[str length]];
        NSUInteger parentLoc = [ret rangeOfString:parentName].location;
        if(parentLoc == NSNotFound)return nil;
        NSString* scans = [ret substringFromIndex:parentLoc+[parentName length]];
        NSScanner* mscanner = [NSScanner scannerWithString:scans];
        NSInteger nObjNumber,nGenNumber;
        [mscanner scanInteger:&nObjNumber];
        [mscanner scanInteger:&nGenNumber];
        
        if(nObjNumber!=objNumber || nGenNumber!=genNumber)
        {
            return [self formIndirectObjectFrom:str WithName:name  NewValue:value ObjectNumber:objectNumber GenerationNumber:generationNumber Type:type  BehindIndex:searchLocation];
        }
    }
    
    if([value isKindOfClass:[NSNull class]])return ret;
    
    if(type != PDFFormTypeButton)
    {
        if([ret rangeOfString:@"/V"].location!=NSNotFound)
        {
            NSUInteger c = [ret rangeOfString:@"/V"].location;
            NSMutableString* oldval = [NSMutableString stringWithString:@"/V"];c++;
            NSUInteger dc = 0;
            while(dc < 1)
            {
                c++;
                unichar append = [ret characterAtIndex:c];
                [oldval appendString:[NSString stringWithCharacters:&append length:1]];
                
                if([ret characterAtIndex:c] == '/')dc++;
                if([ret characterAtIndex:c] == '>')dc++;
            }
            NSString* val = [oldval substringToIndex:oldval.length-1];
            
            if(value == nil)value = @"";
            return [ret stringByReplacingOccurrencesOfString:val withString:[NSString stringWithFormat:@"/V(%@)",value]];
        }
        else 
        {
            if(value == nil)value = @"";
            return [ret stringByReplacingOccurrencesOfString:search withString:[NSString stringWithFormat:@"%@/V(%@)",search,value]];
        }
    }
    else 
    {
        if([ret rangeOfString:@"/V"].location!=NSNotFound)
        {
            NSUInteger c = [ret rangeOfString:@"/V"].location;
            NSMutableString* oldval = [NSMutableString stringWithString:@"/V"];c++;
            NSUInteger dc = 0;
            while(dc < 2)
            {
                c++;
                unichar append = [ret characterAtIndex:c];
                [oldval appendString:[NSString stringWithCharacters:&append length:1]];
                
                if([ret characterAtIndex:c] == '/')dc++;
                if([ret characterAtIndex:c] == '>')dc++;
            }
            NSString* val = [oldval substringToIndex:oldval.length-1];
            if(value == nil)value = @"";
            NSString* set = [value stringByReplacingOccurrencesOfString:@" " withString:@"#20"];
            return [ret stringByReplacingOccurrencesOfString:val withString:[@"/V/" stringByAppendingString:set]];
        }
        else 
        {
            if(value == nil)value = @"";
            NSString* set = [value stringByReplacingOccurrencesOfString:@" " withString:@"#20"];
            return [ret stringByReplacingOccurrencesOfString:search withString:[[NSString stringWithFormat:@"%@/V/",search] stringByAppendingString:set]];
        }
    }
}

-(NSString*)constructTrailer:(NSString*)file FinalOffset:(NSUInteger)fo
{
    NSUInteger trailerloc = [file rangeOfString:@"trailer" options:NSBackwardsSearch].location;
    NSUInteger startxrefloc = [file rangeOfString:@"startxref" options:NSBackwardsSearch].location;
    
    NSScanner* scanner = [NSScanner scannerWithString:[file substringFromIndex:startxrefloc+[@"startxref" length]+1]];
    NSInteger newPrevValInt;
    [scanner scanInteger:&newPrevValInt];
    NSString* newPrevVal = [NSString stringWithFormat:@"%u",(unsigned int)newPrevValInt];
    NSString* trailer = [file substringWithRange:NSMakeRange(trailerloc+[@"trailer" length]+1, startxrefloc-trailerloc-1-[@"trailer" length]-1)];
    NSString* newTrailer = nil;
    
    if([trailer rangeOfString:@"/Prev"].location != NSNotFound)
    {
        NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"/Prev [0-9]*" options:0 error:NULL];
        newTrailer = [reg stringByReplacingMatchesInString:trailer options:0 range:NSMakeRange(0, [trailer length]) withTemplate:[NSString stringWithFormat:@"/Prev %@",newPrevVal]];
    }
    else 
    {
        newTrailer = [trailer stringByReplacingOccurrencesOfString:@"/Size" withString:[NSString stringWithFormat:@"/Prev %@/Size",newPrevVal]];
    }
   
    return [[NSString stringWithFormat:@"trailer\r%@\rstartxref\r%u\r",newTrailer,(unsigned int)fo] stringByAppendingString:@"%%EOF"];
}


-(NSString*)formXML
{
    return [self.forms formXML];
}





-(NSString*)codeForObjectWithNumber:(NSInteger)objectNumber GenerationNumber:(NSInteger)generationNumber
{
    NSMutableString* code = [self sourceCode];
    NSUInteger startxrefOffsetEnd = [code rangeOfString:@"startxref" options:NSBackwardsSearch].location+9;
    NSScanner* scanner = [NSScanner scannerWithString:[code substringFromIndex:startxrefOffsetEnd]];
    NSInteger firstCrossReferenceTableOffset;
    [scanner scanInteger:&firstCrossReferenceTableOffset];

    
    //todo
    
    return nil;
}


-(PDFDictionary*)getTrailer
{
    NSMutableString* code = [self sourceCode];

    NSUInteger trailerStartMarker = [code rangeOfString:@"trailer" options:NSBackwardsSearch].location;
    NSUInteger trailerEndMarker = [code rangeOfString:@"startxref" options:NSBackwardsSearch].location;
    
    while ([code characterAtIndex:trailerStartMarker]!='<') {
        trailerStartMarker++;
    }
    
    return [[[PDFDictionary alloc] initWithPDFRepresentation:[code substringWithRange:NSMakeRange(trailerStartMarker, trailerEndMarker-trailerStartMarker)]] autorelease];
    
}


@end
