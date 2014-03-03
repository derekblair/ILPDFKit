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
                       NSNumberFormatter *ft = [[NSNumberFormatter alloc] init];
                       [ft setNumberStyle:NSNumberFormatterDecimalStyle];
                       [ft setMaximumFractionDigits:3];
                       [[NSString stringWithFormat:@"/Rect[\\s]*\\[[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*\\]",[ft stringFromNumber:rawRect[0]],[ft stringFromNumber:rawRect[1]],[ft stringFromNumber:rawRect[2]],[ft stringFromNumber:rawRect[3]]] stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
                   });
                   
                   NSString* uniqueSearchIdentifierB =
                   
                   ({
                       NSNumberFormatter *ft = [[NSNumberFormatter alloc] init];
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
        
                sourceCode = nil;
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
    
    return [NSString stringWithFormat:@"%lu %lu obj\n%@endobj",(unsigned long)*objectNumber,(unsigned long)*generationNumber,updatedRepresentation];
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

@end
