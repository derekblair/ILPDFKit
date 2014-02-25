//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFSerializer.h"
#import "PDF.h"
#import "PDFUtility.h"


@interface PDFSerializer()
+(NSString*)indirectObjectFrom:(NSString*)str withUniqueIdentifiers:(NSArray*)idents newValue:(NSString*)value objectNumber:(NSUInteger*)objectNumber generationNumber:(NSUInteger*)generationNumber type:(PDFFormType)type;
+(NSString*)constructTrailer:(NSString*)file FinalOffset:(NSUInteger)fo;
@end

@implementation PDFSerializer


+(void)saveDocumentChanges:(NSMutableData*)baseData basedOnForms:(id<NSFastEnumeration>)forms  completion:(void (^)(BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
                NSString* sourceCode = [[NSString alloc] initWithData:baseData encoding:NSASCIIStringEncoding];
                BOOL isSuccess = YES;
                NSMutableString* retval = [NSMutableString string];
                NSMutableArray* names = [NSMutableArray array];
        
                for(PDFForm* form in forms){
                    
                   if(form.modified == NO)continue;
                   if([names containsObject:form.name])continue;
                   [names addObject:form.name];
                   form.modified = NO;
                   NSUInteger objectNumber;
                   NSUInteger generationNumber;
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
                   
                    NSString* indirectObject  = [PDFSerializer indirectObjectFrom:sourceCode withUniqueIdentifiers:@[uniqueSearchIdentifierA,uniqueSearchIdentifierB]  newValue:form.value objectNumber:&objectNumber generationNumber:&generationNumber type:form.formType];
                   if(indirectObject)
                   {
                       NSString* objectNumberString = [NSString stringWithFormat:@"%u",(unsigned int)objectNumber];
                       NSString* generationNumberString = [NSString stringWithFormat:@"%05u",(unsigned int)generationNumber];
                       NSString* offsetString = [NSString stringWithFormat:@"%010u",(unsigned int)([baseData length]+1+[retval length])];
                       
                       [retval appendFormat:@"\r%@\rxref\r0 1\r0000000000 65535 f\r\n%@ 1\r%@ %@ n\r\n",indirectObject,objectNumberString,offsetString,generationNumberString];
                       NSUInteger finalOffset = [retval rangeOfString:@"xref" options:NSBackwardsSearch].location+[baseData length];
                       [retval appendString:[self constructTrailer:[sourceCode stringByAppendingString:retval] FinalOffset:finalOffset]];
                   }
                   else isSuccess = NO;
               }
        
               [sourceCode release];
               [baseData appendData:[retval dataUsingEncoding:NSASCIIStringEncoding]];
                   dispatch_async(dispatch_get_main_queue(), ^{
                       completion(isSuccess);
                   });
        
            });
}



+(NSString*)indirectObjectFrom:(NSString*)str withUniqueIdentifiers:(NSArray*)idents  newValue:(NSString*)value objectNumber:(NSUInteger*)objectNumber generationNumber:(NSUInteger*)generationNumber type:(PDFFormType)type
{
    NSRange searchRange;
    searchRange.location = NSNotFound;
    
    for(int c = 0; searchRange.location == NSNotFound && c < idents.count;c++)
    {
        searchRange = [[NSRegularExpression regularExpressionWithPattern:idents[c] options:0 error:NULL] rangeOfFirstMatchInString:str options:0 range:NSMakeRange(0, str.length) ];
    }
    
    NSUInteger objKeyWordLength = [@"obj" length];
    
    if(searchRange.location == NSNotFound)return nil;
    
    NSUInteger startMarkerLocation = [str rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, searchRange.location+1)].location;
    if(startMarkerLocation == NSNotFound)return nil;
   
    NSString* objectCode = [str substringWithRange:NSMakeRange(startMarkerLocation+objKeyWordLength, [[str substringFromIndex:startMarkerLocation] rangeOfString:@"endobj"].location-objKeyWordLength)];

    NSUInteger startLocation = startMarkerLocation;
    while([str characterAtIndex:startLocation]!='\n' && [str characterAtIndex:startLocation]!='\r')startLocation--;
    
    NSString* objectLine = [str substringWithRange:NSMakeRange(startLocation, startMarkerLocation-startLocation+1+objKeyWordLength)];
    NSScanner* scanner = [NSScanner scannerWithString:objectLine];
    [scanner scanInteger:(NSInteger*)objectNumber];
    [scanner scanInteger:(NSInteger*)generationNumber];
    
    PDFDictionary* tempDict= [[PDFDictionary alloc] initWithPDFRepresentation:objectCode];
    if(value == nil)value = @"";
    if(type == PDFFormTypeButton)[value setAsName:YES];
    NSString* updatedRepresentation = [tempDict updatedRepresentation:@{@"V":value}];
    [tempDict release];
    
    return [NSString stringWithFormat:@"%u %u obj\n%@endobj",*objectNumber,*generationNumber,updatedRepresentation];
}

+(NSString*)constructTrailer:(NSString*)file FinalOffset:(NSUInteger)fo
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
    }
    else
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

// Do not venture beyond here. Crazy broken code lies beyond.

/*
+(NSArray*)pdfObjectsParsedFormObjectStream:(NSString*)stream number:(NSUInteger)number
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
*/

/*
+(NSString*)appendedStringForObjStmObjectWithSearchA:(NSString*)searchA searchB:(NSString*)searchB form:(PDFForm*)form source:(NSString*)sourceCode baseData:(NSData*)baseData currentAppendedString:(NSString*)curAppend
{
    
    
    __block NSUInteger objectNumber;
    __block NSUInteger generationNumber;
    
    __block   NSRange searchRange;
    searchRange.location = NSNotFound;
    __block NSString* streamCompressedObject = nil;
    __block NSString* streamDecompressedData = nil;
    __block NSString* streamTargetIndirectObject = nil;
    
    [[NSRegularExpression regularExpressionWithPattern:@"ObjStm" options:0 error:NULL] enumerateMatchesInString:sourceCode options:0 range:NSMakeRange(0, sourceCode.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSUInteger start = result.range.location;
        NSUInteger objEnd = [sourceCode rangeOfString:@"stream" options:0 range:NSMakeRange(start, sourceCode.length-start)].location-1;
        NSUInteger objStart = [sourceCode rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, start)].location+[@"obj" length];
        NSUInteger outerObjStart = objStart - [@"obj" length];
        
        
        
        while([sourceCode characterAtIndex:outerObjStart]!='\n' && [sourceCode characterAtIndex:outerObjStart]!='\r')outerObjStart--;
        
        
        NSUInteger outerObjEnd = [sourceCode rangeOfString:@"endobj" options:0    range:NSMakeRange(objStart,sourceCode.length-objStart)].location +[@"endobj" length];
        
        PDFDictionary* streamDictionary = [[PDFDictionary alloc] initWithPDFRepresentation:[sourceCode substringWithRange:NSMakeRange(objStart, objEnd-objStart+1)]];
        
        BOOL needsInflation = NO;
        
        if([[streamDictionary objectForKey:@"Filter"] isEqualToString:@"FlateDecode"])
        {
            needsInflation = YES;
        }
        
        NSUInteger streamDataStart = objEnd+1+[@"stream" length];
        NSUInteger streamDataEnd = [sourceCode rangeOfString:@"endstream" options:0 range:NSMakeRange(streamDataStart, sourceCode.length-streamDataStart)].location-2;
        if([sourceCode characterAtIndex:streamDataStart] == '\r')streamDataStart+=2;
        else if ([sourceCode characterAtIndex:streamDataStart] == '\n')streamDataStart++;
        
        NSUInteger properLength = [[streamDictionary objectForKey:@"Length"] integerValue];
        NSUInteger supposedLength = (streamDataEnd-streamDataStart+1);
        
        if(supposedLength > properLength)
        {
            supposedLength = properLength;
        }
        
        
        NSString* resultString = nil;
        
        if(needsInflation)
        {
            NSData* stringData = [PDFUtility zlibInflate:[baseData subdataWithRange:NSMakeRange(streamDataStart, supposedLength)] ] ;
            resultString = [[[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding] autorelease];
        }else
        {
            resultString = [sourceCode substringWithRange:NSMakeRange(streamDataStart, supposedLength)];
        }
        
        searchRange.location = NSNotFound;
        
        searchRange = [[NSRegularExpression regularExpressionWithPattern:searchA options:0 error:NULL] rangeOfFirstMatchInString:resultString options:0 range:NSMakeRange(0, resultString.length) ];
        
        if(searchRange.location == NSNotFound)
        {
            searchRange = [[NSRegularExpression regularExpressionWithPattern:searchB options:0 error:NULL] rangeOfFirstMatchInString:resultString options:0 range:NSMakeRange(0, resultString.length) ];
        }
        
        if(searchRange.location != NSNotFound)
        {
            
            streamDecompressedData = resultString;
            streamCompressedObject = [sourceCode substringWithRange:NSMakeRange(outerObjStart, outerObjEnd-outerObjStart+1)];
            streamTargetIndirectObject = [self indirectObjectFrom:[[self pdfObjectsParsedFormObjectStream:resultString number:[[streamDictionary objectForKey:@"N"] integerValue] ] componentsJoinedByString:@"\n" ]  withUniqueIdentifiers:@[searchA,searchB] newValue:form.value objectNumber:&objectNumber generationNumber:&generationNumber type:form.formType];
            *stop = YES;
        }
    }];
    
    
    if(streamTargetIndirectObject)
    {
        
        NSInteger streamObjectNumber;
        NSInteger streamGenerationNumber;
        NSScanner* scanner = [NSScanner scannerWithString:streamCompressedObject];
        [scanner scanInteger:&streamObjectNumber];
        [scanner scanInteger:&streamGenerationNumber];
        
        NSString* objStreamIndirectObjectHeader = [NSString stringWithFormat:@"%u %u obj",objectNumber,generationNumber];
        
        
        NSString* updateStreamBody = [[[streamTargetIndirectObject stringByReplacingOccurrencesOfString:objStreamIndirectObjectHeader withString:[NSString stringWithFormat:@"%u %u",objectNumber,generationNumber]] stringByReplacingOccurrencesOfString:@"endobj" withString:@""] stringByTrimmingCharactersInSet:[PDFUtility whiteSpaceCharacterSet]];
        
        
        
        
        
        NSString* xrefTrailerHeaderDictionary = (
                                                 
                                                 {
                                                     NSUInteger lastRoot = [sourceCode rangeOfString:@"/XRef" options:NSBackwardsSearch].location;
                                                     NSUInteger start = [sourceCode rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, lastRoot)].location+[@"obj" length];
                                                     NSUInteger end = [sourceCode rangeOfString:@"stream" options:0 range:NSMakeRange(start, sourceCode.length-start)].location-1;
                                                     xrefTrailerHeaderDictionary = [sourceCode substringWithRange:NSMakeRange(start, end-start+1)];
                                                     
                                                     
                                                 });
        
        
        
        PDFDictionary* xrefTrailerHeaderDictionaryObj = [[[PDFDictionary alloc] initWithPDFRepresentation:xrefTrailerHeaderDictionary ] autorelease];
        
        
        
        NSUInteger updateObjStmObjectNumber = streamObjectNumber;
        NSUInteger updateXRefStmObjectNumber = 999999;
        
        
        NSUInteger updateObjectOffset = (unsigned int)([baseData length]+1+[curAppend length]);
        NSUInteger updateXRefStmSize = 999999;
        
        
        NSUInteger lastRoot = [sourceCode rangeOfString:@"/XRef" options:NSBackwardsSearch].location;
        NSUInteger updateXRefStmPrev = [sourceCode rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, lastRoot)].location;
        while([sourceCode characterAtIndex:updateXRefStmPrev]!='\n' && [sourceCode characterAtIndex:updateXRefStmPrev]!='\r')updateXRefStmPrev--;
        updateXRefStmPrev++;
        
        
        NSString* updateObj = [NSString stringWithFormat:@"%u %u obj\n<</First %u/Length %u /Filter/ASCIIHexDecode /N 1 /Type/ObjStm /Extends %u %u R >>\nstream\n%@\nendstream\nendobj",updateObjStmObjectNumber,0,[updateStreamBody rangeOfString:@"<<"].location,updateStreamBody.length,streamObjectNumber,streamGenerationNumber,updateStreamBody];
        
        
        NSUInteger updateXRefStmOffset = updateObjectOffset+1+[updateObj length];
        
        
        
        NSString* updateXrefStmBody = [[NSString stringWithFormat:@"01 %06x 00\n01 %06x 00",updateObjectOffset,updateXRefStmOffset] uppercaseString];
        
        
        
        NSString* filterName = @"ASCIIHexDecode";[filterName setAsName:YES];
        
        NSDictionary* updateDif = @{@"Filter":filterName,@"DecodeParms":[NSNull null],@"Size":[NSNumber numberWithUnsignedInteger:updateXRefStmSize],@"Length":[NSNumber numberWithUnsignedInteger:updateXrefStmBody.length],@"W":[[[PDFArray alloc] initWithPDFRepresentation:@"[1 3 1]"] autorelease],@"Prev":[NSNumber numberWithUnsignedInteger:updateXRefStmPrev]};
        
        NSString* updateTrailerXrefStm = [NSString stringWithFormat:@"%u %u obj\n%@\nstream\n%@\nendstream\nendobj",updateXRefStmObjectNumber,0,[xrefTrailerHeaderDictionaryObj updatedRepresentation:updateDif],updateXrefStmBody];
        
        
        NSString* finalAppend = [NSString stringWithFormat:@"\n%@\n%@\nstartxref\n%u\n",updateObj,updateTrailerXrefStm,updateXRefStmOffset];
        
        
        return finalAppend;
    }else return nil;

    
}*/


@end
