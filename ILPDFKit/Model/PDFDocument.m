
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
    -(NSString*)formIndirectObjectFrom:(NSString*)str WithUniqueIdentifiers:(NSArray*)idents NewValue:(NSString*)value ObjectNumber:(NSUInteger*)objectNumber GenerationNumber:(NSUInteger*)generationNumber Type:(PDFFormType)type;
    -(NSString*)constructTrailer:(NSString*)file FinalOffset:(NSUInteger)fo;
    -(NSString*)constructXRefStream;
    -(NSString*)sourceCode;
@end



@interface PDFDocument(Parsing)
    -(NSArray*)pdfObjectsParsedFormObjectStream:(NSString*)stream number:(NSUInteger)number;

@end

@implementation PDFDocument
{
    NSString* _sourceCode;
    NSString* _documentPath;
    PDFDictionary* _catalog;
    PDFDictionary* _info;
    PDFFormContainer* _forms;
    NSArray* _pages;
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


-(void)saveFormsToDocumentData:(void (^)(BOOL success))completion
{

    dispatch_async(
       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           

           NSMutableString* retval = [NSMutableString string];
           NSMutableArray* names = [NSMutableArray array];
           for(PDFForm* form in _forms)
           {
               if(form.modified == NO)continue;
               if([names containsObject:form.name])continue;
               [names addObject:form.name];
               form.modified = NO;
               __block NSUInteger objectNumber ;//= form.dictionary.objectNumber;
               __block NSUInteger generationNumber ;//= form.dictionary.generationNumber;
               
               
               NSString* indirectObject = nil;
               
               
               NSArray* rawRect = form.rawRect;
               
               
               NSString* uniqueSearchIdentifierA =
             
               ({
                   NSNumberFormatter *ft = [[[NSNumberFormatter alloc] init] autorelease];
                   [ft setNumberStyle:NSNumberFormatterDecimalStyle];
                   [ft setMaximumFractionDigits:3];
                   [[NSString stringWithFormat:@"/Rect[\\s]*\\[[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*\\]",[ft stringFromNumber:rawRect[0]],[ft stringFromNumber:rawRect[1]],[ft stringFromNumber:rawRect[2]],[ft stringFromNumber:rawRect[3]]] stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
               });
               
               
               
               NSString* uniqueSearchIdentifierB =
               
               ({
                   NSNumberFormatter *ft = [[[NSNumberFormatter alloc] init] autorelease];
                   [ft setNumberStyle:NSNumberFormatterDecimalStyle];
                   [ft setMaximumFractionDigits:4];
                   [[NSString stringWithFormat:@"/Rect[\\s]*\\[[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*\\]",[ft stringFromNumber:rawRect[0]],[ft stringFromNumber:rawRect[1]],[ft stringFromNumber:rawRect[2]],[ft stringFromNumber:rawRect[3]]] stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
               });

    
               BOOL usesObjectStreams = NO;
               if([self.sourceCode rangeOfString:@"ObjStm"].location!=NSNotFound)usesObjectStreams = YES;
               
               
              
               {
                   indirectObject = [self formIndirectObjectFrom:self.sourceCode  WithUniqueIdentifiers:@[uniqueSearchIdentifierA,uniqueSearchIdentifierB] NewValue:form.value ObjectNumber:&objectNumber GenerationNumber:&generationNumber Type:form.formType];
               
                   
                   if(indirectObject)
                   {
                       NSString* objectNumberString = [NSString stringWithFormat:@"%u",(unsigned int)objectNumber];
                       NSString* generationNumberString = [NSString stringWithFormat:@"%05u",(unsigned int)generationNumber];
                       NSString* offsetString = [NSString stringWithFormat:@"%010u",(unsigned int)([self.documentData length]+1+[retval length])];
                       
                       [retval appendFormat:@"\r%@\rxref\r0 1\r0000000000 65535 f\r\n%@ 1\r%@ %@ n\r\n",indirectObject,objectNumberString,offsetString,generationNumberString];
                       NSUInteger finalOffset = [retval rangeOfString:@"xref" options:NSBackwardsSearch].location+[self.documentData length];
                       [retval appendString:[self constructTrailer:[self.sourceCode stringByAppendingString:retval] FinalOffset:finalOffset]];
                   }
                   else if(usesObjectStreams == YES)
                   {
                       
                       
                       __block   NSRange searchRange;
                       searchRange.location = NSNotFound;
                       __block NSString* streamCompressedObject = nil;
                       __block NSString* streamDecompressedData = nil;
                       __block NSString* streamTargetIndirectObject = nil;
                       
                         [[NSRegularExpression regularExpressionWithPattern:@"ObjStm" options:0 error:NULL] enumerateMatchesInString:self.sourceCode options:0 range:NSMakeRange(0, self.sourceCode.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {

                             NSUInteger start = result.range.location;
                             NSUInteger objEnd = [_sourceCode rangeOfString:@"stream" options:0 range:NSMakeRange(start, _sourceCode.length-start)].location-1;
                             NSUInteger objStart = [_sourceCode rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, start)].location+[@"obj" length];
                             NSUInteger outerObjStart = objStart - [@"obj" length];
                             
                             
                             
                             while([_sourceCode characterAtIndex:outerObjStart]!='\n' && [_sourceCode characterAtIndex:outerObjStart]!='\r')outerObjStart--;
                             
                             
                             
                             NSUInteger outerObjEnd = [_sourceCode rangeOfString:@"endobj" options:0    range:NSMakeRange(objStart,_sourceCode.length-objStart)].location +[@"endobj" length];
                            
                             PDFDictionary* streamDictionary = [[PDFDictionary alloc] initWithPDFRepresentation:[_sourceCode substringWithRange:NSMakeRange(objStart, objEnd-objStart+1)]];
                             
                             BOOL needsInflation = NO;
                             
                             if([[streamDictionary objectForKey:@"Filter"] isEqualToString:@"FlateDecode"])
                             {
                                 needsInflation = YES;
                             }
                             
                             NSUInteger streamDataStart = objEnd+1+[@"stream" length];
                             NSUInteger streamDataEnd = [_sourceCode rangeOfString:@"endstream" options:0 range:NSMakeRange(streamDataStart, _sourceCode.length-streamDataStart)].location-2;
                             if([_sourceCode characterAtIndex:streamDataStart] == '\r')streamDataStart+=2;
                             else if ([_sourceCode characterAtIndex:streamDataStart] == '\n')streamDataStart++;
            
                             NSUInteger properLength = [[streamDictionary objectForKey:@"Length"] integerValue];
                             NSUInteger supposedLength = (streamDataEnd-streamDataStart+1);
                             
                             if(supposedLength > properLength)
                             {
                                 supposedLength = properLength;
                             }
                    
                             
                             NSString* resultString = nil;
                            
                             if(needsInflation)
                             {
                                 NSData* stringData = [PDFUtility zlibInflate:[_documentData subdataWithRange:NSMakeRange(streamDataStart, supposedLength)] ] ;
                                 resultString = [[[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding] autorelease];
                             }else
                             {
                                 resultString = [_sourceCode substringWithRange:NSMakeRange(streamDataStart, supposedLength)];
                             }
                             
                            searchRange.location = NSNotFound;
                    
                            searchRange = [[NSRegularExpression regularExpressionWithPattern:uniqueSearchIdentifierA options:0 error:NULL] rangeOfFirstMatchInString:resultString options:0 range:NSMakeRange(0, resultString.length) ];
                             
                             if(searchRange.location == NSNotFound)
                             {
                                  searchRange = [[NSRegularExpression regularExpressionWithPattern:uniqueSearchIdentifierB options:0 error:NULL] rangeOfFirstMatchInString:resultString options:0 range:NSMakeRange(0, resultString.length) ];
                             }
    
                             if(searchRange.location != NSNotFound)
                             {
                                
                                 streamDecompressedData = resultString;
                                 streamCompressedObject = [_sourceCode substringWithRange:NSMakeRange(outerObjStart, outerObjEnd-outerObjStart+1)];
                                 streamTargetIndirectObject = [self formIndirectObjectFrom:[[self pdfObjectsParsedFormObjectStream:resultString number:[[streamDictionary objectForKey:@"N"] integerValue] ] componentsJoinedByString:@"\n" ]  WithUniqueIdentifiers:@[uniqueSearchIdentifierA,uniqueSearchIdentifierB] NewValue:form.value ObjectNumber:&objectNumber GenerationNumber:&generationNumber Type:form.formType];
                                 *stop = YES;
                             }
                         }];
                       
                       
                       if(streamTargetIndirectObject)
                       {
                           
                           
                           
                          /* NSString* objectNumberString = [NSString stringWithFormat:@"%u",(unsigned int)objectNumber];
                           NSString* generationNumberString = [NSString stringWithFormat:@"%05u",(unsigned int)generationNumber];
                           NSString* offsetString = [NSString stringWithFormat:@"%010u",(unsigned int)([self.documentData length]+1+[retval length])];
                           
                           [retval appendFormat:@"\r%@\rxref\r0 1\r0000000000 65535 f\r\n%@ 1\r%@ %@ n\r\n",streamTargetIndirectObject,objectNumberString,offsetString,generationNumberString];
                           NSUInteger finalOffset = [retval rangeOfString:@"xref" options:NSBackwardsSearch].location+[self.documentData length];
                           [retval appendString:[self constructTrailer:[self.sourceCode stringByAppendingString:retval] FinalOffset:finalOffset]];*/
                           
                           
                           
                           
                           
                           
                           
                          //NSInteger streamObjectNumber;
                          // NSInteger streamGenerationNumber;
                           
                           
                          // NSScanner* scanner = [NSScanner scannerWithString:streamCompressedObject];
                           
                          // [scanner scanInteger:&streamObjectNumber];
                          // [scanner scanInteger:&streamGenerationNumber];
                           
                          // NSString* indirectObjectHeader = [NSString stringWithFormat:@"%u %u obj",objectNumber,generationNumber];
                           
                           
                          // NSString* updateStreamBody = [[[streamTargetIndirectObject stringByReplacingOccurrencesOfString:indirectObjectHeader withString:[NSString stringWithFormat:@"%u %u",objectNumber,generationNumber]] stringByReplacingOccurrencesOfString:@"endobj" withString:@""] stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
                           
                           
                          
                           
                          
                           NSString* xrefTrailerHeaderDictionary = (
                           
                           {
                                NSUInteger lastRoot = [_sourceCode rangeOfString:@"/XRef" options:NSBackwardsSearch].location;
                               NSUInteger start = [_sourceCode rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, lastRoot)].location+[@"obj" length];
                               NSUInteger end = [_sourceCode rangeOfString:@"stream" options:0 range:NSMakeRange(start, _sourceCode.length-start)].location-1;
                               xrefTrailerHeaderDictionary = [_sourceCode substringWithRange:NSMakeRange(start, end-start+1)];
                               
                               
                           });
                           

                           
                           PDFDictionary* xrefTrailerHeaderDictionaryObj = [[[PDFDictionary alloc] initWithPDFRepresentation:xrefTrailerHeaderDictionary ] autorelease];
                           
                           
                          // NSString* rawUpdate = [[[NSString alloc] initWithData:[PDFUtility zlibDeflate:[updateStreamBody dataUsingEncoding:NSASCIIStringEncoding]] encoding:NSASCIIStringEncoding] autorelease];
                           
                           
                           
                          // NSUInteger updateObjStmObjectNumber = objectNumber;
                           //[[xrefTrailerHeaderDictionaryObj objectForKey:@"Size"] unsignedIntegerValue];
                           NSUInteger updateXRefStmObjectNumber = 999999;
                           
                           
                           
                           NSUInteger updateObjectOffset = (unsigned int)([self.documentData length]+1+[retval length]);
                           
                           NSUInteger updateXRefStmSize = 999999;
                           
                           
                            NSUInteger lastRoot = [_sourceCode rangeOfString:@"/XRef" options:NSBackwardsSearch].location;
                           NSUInteger updateXRefStmPrev = [_sourceCode rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, lastRoot)].location;
                           while([_sourceCode characterAtIndex:updateXRefStmPrev]!='\n' && [_sourceCode characterAtIndex:updateXRefStmPrev]!='\r')updateXRefStmPrev--;
                           updateXRefStmPrev++;
                           
                           
                           //NSString* updateObj = [NSString stringWithFormat:@"%u %u obj\n<</First %u/Length %u /Filter/FlateDecode /N 1 /Type/ObjStm /Extends %u %u R >>\nstream\n%@\nendstream\nendobj",updateObjStmObjectNumber,0,[updateStreamBody rangeOfString:@"<<"].location,rawUpdate.length,streamObjectNumber,streamGenerationNumber,rawUpdate];
                           
                           
                           NSUInteger updateXRefStmOffset = updateObjectOffset+1+[streamTargetIndirectObject length];
                           
                           
                           
                           NSString* updateXrefStmBody = [[NSString stringWithFormat:@"01 %06x 00\n01 %06x 00",updateObjectOffset,updateXRefStmOffset] uppercaseString];
                           
                           
                           
                           NSString* filterName = @"ASCIIHexDecode";[filterName setAsName:YES];
                           
                           NSDictionary* updateDif = @{@"Filter":filterName,@"DecodeParms":[NSNull null],@"Size":[NSNumber numberWithUnsignedInteger:updateXRefStmSize],@"Length":[NSNumber numberWithUnsignedInteger:updateXrefStmBody.length],@"W":[[[PDFArray alloc] initWithPDFRepresentation:@"[1 3 1]"] autorelease],@"Prev":[NSNumber numberWithUnsignedInteger:updateXRefStmPrev]};
                           
                           NSString* updateTrailerXrefStm = [NSString stringWithFormat:@"%u %u obj\n%@\nstream\n%@\nendstream\nendobj",updateXRefStmObjectNumber,0,[xrefTrailerHeaderDictionaryObj updatedRepresentation:updateDif],updateXrefStmBody];
                           
                           
                           NSString* finalAppend = [NSString stringWithFormat:@"\n%@\n%@\nstartxref\n%u\n",streamTargetIndirectObject,updateTrailerXrefStm,updateXRefStmOffset];
                           
                           
                           
                           
                           [retval appendString:[finalAppend stringByAppendingString:@"%%EOF"]];
                       
                       }
                           else
                       {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               completion(NO);
                           });
                           return ;
                       }
                       
                       
                       
                   }
                   else
                   {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           completion(NO);
                       });
                       return ;
                   }
               }
               
           }
           
           [self.documentData appendData:[retval dataUsingEncoding:NSASCIIStringEncoding]];
           dispatch_async(dispatch_get_main_queue(), ^{
               completion(YES);
           });
       });

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

-(NSString*)sourceCode
{
    if(_sourceCode == nil)
    {
        _sourceCode = [[NSString alloc] initWithData:self.documentData encoding:NSASCIIStringEncoding];
       
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

-(NSUInteger)numberOfPages
{
    return CGPDFDocumentGetNumberOfPages(_document);
}

#pragma mark - PDF File Saving

-(NSString*)formIndirectObjectFrom:(NSString*)str WithUniqueIdentifiers:(NSArray*)idents  NewValue:(NSString*)value ObjectNumber:(NSUInteger*)objectNumber GenerationNumber:(NSUInteger*)generationNumber Type:(PDFFormType)type
{
    NSRange searchRange;
    searchRange.location = NSNotFound;
    
    for(int c = 0; searchRange.location == NSNotFound && c < idents.count;c++)
    {
        searchRange = [[NSRegularExpression regularExpressionWithPattern:idents[c] options:0 error:NULL] rangeOfFirstMatchInString:str options:0 range:NSMakeRange(0, str.length) ];
    }
    
    if(searchRange.location == NSNotFound)return nil;
    NSString* ident = [str substringWithRange:searchRange];
    NSUInteger startMarkerLocation = [str rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, searchRange.location+1)].location;
    if(startMarkerLocation == NSNotFound)return nil;
    
    NSUInteger startLocation = startMarkerLocation;
    while([str characterAtIndex:startLocation]!='\n' && [str characterAtIndex:startLocation]!='\r')startLocation--;
    
    NSString* objectLine = [str substringWithRange:NSMakeRange(startLocation+1, startMarkerLocation-startLocation)];
    
    NSScanner* scanner = [NSScanner scannerWithString:objectLine];
    [scanner scanInteger:(NSInteger*)objectNumber];
    [scanner scanInteger:(NSInteger*)generationNumber];
    NSString* ret =  [str substringWithRange:NSMakeRange(startLocation+1, [[str substringFromIndex:startLocation+1] rangeOfString:@"endobj"].location+[@"endobj" length])];
    
    
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
                if([ret characterAtIndex:c] == '>')
                {
                    dc++;
                    if((ret.length > c+1) && [ret characterAtIndex:c+1] == '>')
                    {
                        // dictionary
                    }
                    else
                    {
                        [oldval appendString:@" "];
                    }
                }
            }
            NSString* val = [oldval substringToIndex:oldval.length-1];
            
            
            if(value == nil)value = @"";
            return [ret stringByReplacingOccurrencesOfString:val withString:[NSString stringWithFormat:@"/V(%@)",value]];
        }
        else 
        {
            if(value == nil)value = @"";
            return [ret stringByReplacingOccurrencesOfString:ident withString:[NSString stringWithFormat:@"%@/V(%@)",ident,value]];
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
            return [ret stringByReplacingOccurrencesOfString:ident withString:[[NSString stringWithFormat:@"%@/V/",ident] stringByAppendingString:set]];
        }
    }
    return nil;
}



-(NSString*)constructXRefStream
{
    return nil;
}

-(NSString*)constructTrailer:(NSString*)file FinalOffset:(NSUInteger)fo
{
    NSUInteger trailerloc = [file rangeOfString:@"trailer" options:NSBackwardsSearch].location;
    NSUInteger startxrefloc = [file rangeOfString:@"startxref" options:NSBackwardsSearch].location;
    
    NSScanner* scanner = [NSScanner scannerWithString:[file substringFromIndex:startxrefloc+[@"startxref" length]+1]];
    NSInteger newPrevValInt;
    [scanner scanInteger:&newPrevValInt];
    NSString* newPrevVal = [NSString stringWithFormat:@"%u",(unsigned int)newPrevValInt];
    
    NSString* newTrailer = nil;
    if(trailerloc!=NSNotFound)
    {
        NSString* trailer = [file substringWithRange:NSMakeRange(trailerloc+[@"trailer" length]+1, startxrefloc-trailerloc-1-[@"trailer" length]-1)];
        
        
        if([trailer rangeOfString:@"/Prev"].location != NSNotFound)
        {
            NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"/Prev [0-9]*" options:0 error:NULL];
            newTrailer = [reg stringByReplacingMatchesInString:trailer options:0 range:NSMakeRange(0, [trailer length]) withTemplate:[NSString stringWithFormat:@"/Prev %@",newPrevVal]];
        }
        else 
        {
            newTrailer = [trailer stringByReplacingOccurrencesOfString:@"/Size" withString:[NSString stringWithFormat:@"/Prev %@/Size",newPrevVal]];
        }
    }else
    {
        
        NSUInteger lastRoot = [file rangeOfString:@"/XRef" options:NSBackwardsSearch].location;
        
        if(lastRoot != NSNotFound)
        {
            
            NSUInteger start = [file rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, lastRoot)].location+[@"obj" length];
            NSUInteger end = [file rangeOfString:@"stream" options:0 range:NSMakeRange(start, file.length-start)].location-1;
            newTrailer = [file substringWithRange:NSMakeRange(start, end-start+1)];
            newTrailer = [newTrailer stringByReplacingOccurrencesOfString:@"/Size" withString:[NSString stringWithFormat:@"/Prev %@/Size",newPrevVal]];
            
        }
        else
        {
            return nil;
        }
    }
   
    return [[NSString stringWithFormat:@"trailer\r%@\rstartxref\r%u\r",newTrailer,(unsigned int)fo] stringByAppendingString:@"%%EOF"];
}


-(NSString*)formXML
{
    return [self.forms formXML];
}




-(NSArray*)pdfObjectsParsedFormObjectStream:(NSString*)stream number:(NSUInteger)number
{
    NSMutableArray* ret = [NSMutableArray array];
    
    NSUInteger currentStart = 0;
    NSUInteger currentEnd = 0;
    NSUInteger nestCount = 0;
    unichar currentChar = 0;
    
    
    NSScanner* scanner = [NSScanner scannerWithString:stream];
    
    NSMutableArray* objectNumberArray = [NSMutableArray array];
    
    for(int i = 0 ; i < number ; i++)
    {
        NSInteger objectNumber;
        NSInteger offset;
        
        [scanner scanInteger:&objectNumber];
        [scanner scanInteger:&offset];
        
        [objectNumberArray addObject:[NSNumber numberWithInteger:objectNumber]];
        
    }
    
    
    NSUInteger objectOrder = 0;
    
    for(int c = 0; c < stream.length; c++)
    {
        BOOL wasZero = (nestCount == 0);
        
        currentChar  = [stream characterAtIndex:c];
        if(currentChar == '<' || currentChar == '[' || currentChar == '(')nestCount++;
        if(currentChar == '>' || currentChar == ']' || currentChar == ')')nestCount--;
        
        if(nestCount == 1 &&  wasZero)
        {
            currentStart = c;
            
        }
        else if(nestCount == 0 && !wasZero)
        {
            currentEnd = c;
            
            NSString* add = [NSString stringWithFormat:@"%@ 0 obj\n%@\nendobj",[objectNumberArray objectAtIndex:objectOrder],[stream substringWithRange:NSMakeRange(currentStart, currentEnd-currentStart+1)]];
            
            
            [ret addObject:add];
            
            
            objectOrder++;
        }
    }
    
    return ret;
    
    
}


@end
