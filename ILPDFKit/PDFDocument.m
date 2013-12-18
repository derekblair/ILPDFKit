
#import "PDFDocument.h"
#import "PDFForm.h"
#import "PDFDictionary.h"
#import "PDFArray.h"
#import "PDFStream.h"
#import "PDFPage.h"
#import "PDFUtility.h"
#import "PDFFormButtonField.h"
#import "PDFFormContainer.h"
#import "PDF.h"
#import <QuartzCore/QuartzCore.h>
#define isWS(c) ((c) == 0 || (c) == 9 || (c) == 10 || (c) == 12 || (c) == 13 || (c) == 32)

@interface PDFDocument()
    -(NSString*)formIndirectObjectFrom:(NSString*)str WithName:(NSString*)name NewValue:(NSString*)value ObjectNumber:(NSUInteger*)objectNumber GenerationNumber:(NSUInteger*)generationNumber Type:(PDFFormType)type BehindIndex:(NSInteger)index;
    -(NSString*)constructTrailer:(NSString*)file FinalOffset:(NSUInteger)fo;
    -(NSMutableString*)sourceCode;
    -(PDFDictionary*)getTrailerBeforeOffset:(NSUInteger)offset;
    -(NSUInteger)offsetForObjectWithNumber:(NSUInteger)number InSection:(NSUInteger)section;
    -(NSString*)codeForIndirectObjectWithOffset:(NSUInteger)offset;
    @property(nonatomic,readonly) NSArray* crossReferenceSectionsOffsets;

@end

@implementation PDFDocument
{
    NSMutableString* _sourceCode;
    NSString* _documentPath;
    PDFDictionary* _catalog;
    PDFDictionary* _info;
    PDFFormContainer* _forms;
    NSArray* _pages;
    NSArray* _crossReferenceSectionsOffsets;
}




-(void)dealloc
{
   
    self.documentData = nil;
    self.pdfName = nil;
    [_documentPath release];
    [_catalog release];
    [_info release];
    [_pages release];
    [_forms release];
    [_sourceCode release];
    [_crossReferenceSectionsOffsets release];
    CGPDFDocumentRelease(_document);
    [super dealloc];
}

-(id)initWithData:(NSData *)data
{
    self = [super init];
    if(self != nil)
    {
        _document = [PDFUtility createPDFDocumentRefFromData:data];
        _documentData = [[NSMutableData alloc] initWithData:data];
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
        _document = [PDFUtility createPDFDocumentRefFromResource:name];
        _documentPath = [[[NSBundle mainBundle] pathForResource:name ofType:@"pdf"] retain];
        
        
        
        NSString* test = [self codeForObjectWithNumber:42 GenerationNumber:0];
        
        
        
        test = nil;

    }
    return self;
}

-(id)initWithPath:(NSString*)path
{
    self = [super init];
    if(self != nil)
    {
        _document = [PDFUtility createPDFDocumentRefFromPath:path];
        _documentPath = [path retain];
        
        
        
           }
    return self;
}


-(BOOL)saveFormsToDocumentData
{
    NSMutableString* retval = [NSMutableString string];
    NSMutableArray* names = [NSMutableArray array];
    for(PDFForm* form in _forms)
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
    [_catalog release];_catalog = nil;
    [_pages release];_pages = nil;
    [_info release];_info = nil;
    [_sourceCode release];_sourceCode = nil;
    CGPDFDocumentRelease(_document);_document = NULL;
    _document = [PDFUtility createPDFDocumentRefFromData:self.documentData];
}



#pragma mark - Getter

-(PDFFormContainer*)forms
{
    if(_forms == nil)
    {
        _forms = [[PDFFormContainer alloc] initWithParentDocument:self];
    }
    
    return _forms;
}


-(NSMutableString*)sourceCode
{
    if(_sourceCode == nil)
    {
        _sourceCode = [[NSMutableString alloc] initWithData:self.documentData encoding:NSASCIIStringEncoding];
    }
    
    return _sourceCode;
}

-(NSMutableData*)documentData
{
    if(_documentData == nil)
    {
        _documentData = [[NSMutableData alloc] initWithContentsOfFile:_documentPath options:NSDataReadingMappedAlways error:NULL];
    }
    
    return _documentData;
}

-(PDFDictionary*)catalog
{
    if(_catalog == nil)
    {
        _catalog = [[PDFDictionary alloc] initWithDictionary:CGPDFDocumentGetCatalog(_document)];
    }
    
    return _catalog;
}

-(PDFDictionary*)info
{
    if(_info == nil)
    {
        _info = [[PDFDictionary alloc] initWithDictionary:CGPDFDocumentGetInfo(_document)];
    }
    
    return _info;
}

-(NSArray*)pages
{
    if(_pages == nil)
    {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        
        for(NSUInteger i = 0 ; i < CGPDFDocumentGetNumberOfPages(_document); i++)
        {
            PDFPage* add = [[PDFPage alloc] initWithPage:CGPDFDocumentGetPage(_document,i+1)];
            [temp addObject:add];
            [add release];
        }
        
        _pages = [[NSArray alloc] initWithArray:temp];
        [temp release];
    }
    
    return _pages;
}

-(NSArray*)crossReferenceSectionsOffsets
{
    
    if(_crossReferenceSectionsOffsets == nil)
    {
        NSMutableArray* temp = [NSMutableArray array];
        NSMutableString* code = [self sourceCode];
        NSUInteger bound = code.length;
        NSUInteger markerLength = [@"startxref" length];
        
        
        while(YES){
            
            NSUInteger startxrefOffsetEnd = [code rangeOfString:@"startxref" options:NSBackwardsSearch range:NSMakeRange(0, bound)].location;
            
            if(startxrefOffsetEnd == NSNotFound)
            {
                _crossReferenceSectionsOffsets = [[NSArray alloc] initWithArray:temp];
                break;
            }
            
            NSScanner* scanner = [NSScanner scannerWithString:[code substringFromIndex:startxrefOffsetEnd+markerLength]];
            NSInteger crossReferenceTableOffset;
            [scanner scanInteger:&crossReferenceTableOffset];
            [temp addObject:[NSNumber numberWithInteger:crossReferenceTableOffset]];
            bound = startxrefOffsetEnd;
        }
    }
    
    return _crossReferenceSectionsOffsets;
}

-(NSUInteger)numberOfPages
{
    return CGPDFDocumentGetNumberOfPages(_document);
}

#pragma mark - PDF File Saving

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


#pragma mark - Parsing 


-(NSUInteger)offsetForObjectWithNumber:(NSUInteger)number InSection:(NSUInteger)section
{
    NSUInteger sectionOffset = [[self.crossReferenceSectionsOffsets objectAtIndex:section] unsignedIntegerValue]+[@"xref" length];
    
    NSString* searchStart = [self.sourceCode substringFromIndex:sectionOffset];
    
    
    NSRegularExpression* regexStart = [[NSRegularExpression alloc] initWithPattern:@"[0-9]{1,9} [0-9]{1,4}" options:0 error:NULL];
    
     NSUInteger start = [regexStart rangeOfFirstMatchInString:searchStart options:0 range:NSMakeRange(0, searchStart.length)].location;
    
    
    
    NSScanner* scanner = [NSScanner scannerWithString:[searchStart substringFromIndex:start]];
    NSInteger startingObjectNumber;
    NSInteger objectCount;
    [scanner scanInteger:&startingObjectNumber];
    [scanner scanInt:&objectCount];
    
    
    
    while(1)
    {
        start++;
        char c = [searchStart characterAtIndex:start];
        if(c == 'n' || c == 'f')
        {
            start = start-17;
            break;
        }
    }
    
    NSString* linesStart = [searchStart substringFromIndex:start];
    
    
    if(number >= startingObjectNumber && number<startingObjectNumber+objectCount)
    {
        NSArray* lines = [linesStart componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"nf"]];
        
        NSString* targ = [lines objectAtIndex:number-startingObjectNumber];
        
        
        NSScanner* scanner = [NSScanner scannerWithString:targ];
        
        NSInteger offset = 7;
        
        [scanner scanInteger:&offset];
        
        return (NSUInteger)offset;
        
    }
    
    
    return NSNotFound;
    
    
    
}


 -(NSString*)codeForIndirectObjectWithOffset:(NSUInteger)offset
{
    NSUInteger start = [[self.sourceCode substringFromIndex:offset] rangeOfString:@"obj"].location+[@"obj" length];
    NSUInteger end = [[self.sourceCode substringFromIndex:offset] rangeOfString:@"endobj"].location;
    return [self.sourceCode substringWithRange:NSMakeRange(start, end-start)];
}


-(NSString*)codeForObjectWithNumber:(NSInteger)objectNumber GenerationNumber:(NSInteger)generationNumber
{
   
    NSArray* crossRefSectionOffsets = self.crossReferenceSectionsOffsets;
    for(NSInteger c = 0 ; c <[crossRefSectionOffsets count] ; c++)
    {
        NSUInteger offset = [self offsetForObjectWithNumber:objectNumber InSection:c];
        if(offset!= NSNotFound)
        {
            return [self codeForIndirectObjectWithOffset:offset];
        }
        
    }
    
    return nil;
}


-(PDFDictionary*)getTrailerBeforeOffset:(NSUInteger)offset
{
    NSMutableString* code = [self sourceCode];

    NSUInteger trailerStartMarker = [code rangeOfString:@"trailer" options:NSBackwardsSearch range:NSMakeRange(0, offset)].location;
    NSUInteger trailerEndMarker = [code rangeOfString:@"startxref" options:NSBackwardsSearch range:NSMakeRange(0, offset)].location;
    
    while ([code characterAtIndex:trailerStartMarker]!='<') {
        trailerStartMarker++;
    }
    
    return [[[PDFDictionary alloc] initWithPDFRepresentation:[code substringWithRange:NSMakeRange(trailerStartMarker, trailerEndMarker-trailerStartMarker)] Document:self] autorelease];
    
}


@end
