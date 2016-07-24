// ILPDFSerializer.m
//
// Copyright (c) 2016 Derek Blair
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <ILPDFKit/ILPDFKit.h>
#import "ILPDFSerializer.h"

@interface ILPDFSerializer()
+ (NSString *)indirectObjectFrom:(NSString *)str withUniqueIdentifiers:(NSArray *)idents newValue:(NSString *)value objectNumber:(NSUInteger *)objectNumber generationNumber:(NSUInteger *)generationNumber type:(ILPDFFormType)type;
+ (NSString *)constructTrailer:(NSString *)file finalOffset:(NSUInteger)fo;
@end

@implementation ILPDFSerializer

+ (void)saveDocumentChanges:(NSMutableData *)baseData basedOnForms:(id<NSFastEnumeration>)forms completion:(void (^)(BOOL success))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *sourceCode = [ILPDFUtility stringFromPDFData:baseData];
        BOOL isSuccess = YES;
        NSMutableString *retval = [NSMutableString string];
        NSMutableArray *names = [NSMutableArray array];
        for (ILPDFForm *form in forms) {
           if (!form.modified) continue;
           if ([names containsObject:form.name]) continue;
           [names addObject:form.name];
           NSUInteger objectNumber;
           NSUInteger generationNumber;
           NSArray *rawRect = form.rawRect;
           NSString *uniqueSearchIdentifierA = ({
               NSNumberFormatter *ft = [[NSNumberFormatter alloc] init];
               [ft setNumberStyle:NSNumberFormatterDecimalStyle];
               [ft setMaximumFractionDigits:3];
               [[NSString stringWithFormat:@"/Rect[\\s]*\\[[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*\\]",[ft stringFromNumber:rawRect[0]],[ft stringFromNumber:rawRect[1]],[ft stringFromNumber:rawRect[2]],[ft stringFromNumber:rawRect[3]]] stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
           });
           NSString *uniqueSearchIdentifierB = ({
               NSNumberFormatter *ft = [[NSNumberFormatter alloc] init];
               [ft setNumberStyle:NSNumberFormatterDecimalStyle];
               [ft setMaximumFractionDigits:4];
               [[NSString stringWithFormat:@"/Rect[\\s]*\\[[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*%@[\\s]*\\]",[ft stringFromNumber:rawRect[0]],[ft stringFromNumber:rawRect[1]],[ft stringFromNumber:rawRect[2]],[ft stringFromNumber:rawRect[3]]] stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
           });
           
           NSString *indirectObject  = [ILPDFSerializer indirectObjectFrom:sourceCode withUniqueIdentifiers:@[uniqueSearchIdentifierA,uniqueSearchIdentifierB]  newValue:form.value objectNumber:&objectNumber generationNumber:&generationNumber type:form.formType];
           if (indirectObject) {
               NSString *objectNumberString = [NSString stringWithFormat:@"%u",(unsigned int)objectNumber];
               NSString *generationNumberString = [NSString stringWithFormat:@"%05u",(unsigned int)generationNumber];
               NSString *offsetString = [NSString stringWithFormat:@"%010u",(unsigned int)([baseData length]+1+[retval length])];
               [retval appendFormat:@"\r%@\rxref\r0 1\r0000000000 65535 f\r\n%@ 1\r%@ %@ n\r\n",indirectObject,objectNumberString,offsetString,generationNumberString];
               NSUInteger finalOffset = [retval rangeOfString:@"xref" options:NSBackwardsSearch].location+[baseData length];
               [retval appendString:[self constructTrailer:[sourceCode stringByAppendingString:retval] finalOffset:finalOffset]];
           } else isSuccess = NO;
       }
       sourceCode = nil;
       [baseData appendData:[ILPDFUtility dataFromPDFString:retval]];
       dispatch_async(dispatch_get_main_queue(), ^{
           completion(isSuccess);
       });
    });
}



+ (NSString *)indirectObjectFrom:(NSString *)str withUniqueIdentifiers:(NSArray *)idents  newValue:(NSString *)value objectNumber:(NSUInteger *)objectNumber generationNumber:(NSUInteger *)generationNumber type:(ILPDFFormType)type {
    NSRange searchRange;
    searchRange.location = NSNotFound;
    for (NSUInteger c = 0; searchRange.location == NSNotFound && c < idents.count;c++) {
        searchRange = [[NSRegularExpression regularExpressionWithPattern:idents[c] options:0 error:NULL] rangeOfFirstMatchInString:str options:0 range:NSMakeRange(0, str.length) ];
    }
    NSUInteger objKeyWordLength = [@"obj" length];
    if (searchRange.location == NSNotFound)return nil;
    NSUInteger startMarkerLocation = [str rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, searchRange.location+1)].location;
    if(startMarkerLocation == NSNotFound)return nil;
    NSString *objectCode = [str substringWithRange:NSMakeRange(startMarkerLocation+objKeyWordLength, [[str substringFromIndex:startMarkerLocation] rangeOfString:@"endobj"].location-objKeyWordLength)];
    NSUInteger startLocation = startMarkerLocation;
    while ([str characterAtIndex:startLocation]!='\n' && [str characterAtIndex:startLocation]!='\r') startLocation--;
    NSString *objectLine = [str substringWithRange:NSMakeRange(startLocation, startMarkerLocation-startLocation+1+objKeyWordLength)];
    NSScanner *scanner = [NSScanner scannerWithString:objectLine];
    [scanner scanInteger:(NSInteger *)objectNumber];
    [scanner scanInteger:(NSInteger *)generationNumber];
    ILPDFDictionary *tempDict= [ILPDFDictionary pdfObjectWithRepresentation:[ILPDFUtility dataFromPDFString:objectCode] flags:ILPDFRepOptionNone];
    if (value == nil)value = @"";
    if (type == ILPDFFormTypeButton) value = [[ILPDFName alloc] initWithString:value];
    NSString *updatedRepresentation = [[tempDict dictionaryByMergingDictionary:@{@"V":value}] pdfFileRepresentation];
    return [NSString stringWithFormat:@"%lu %lu obj\n%@endobj",(unsigned long)*objectNumber,(unsigned long)*generationNumber,updatedRepresentation];
}

+ (NSString *)constructTrailer:(NSString *)file finalOffset:(NSUInteger)fo {
    NSUInteger trailerloc = [file rangeOfString:@"trailer" options:NSBackwardsSearch].location;
    NSUInteger startxrefloc = [file rangeOfString:@"startxref" options:NSBackwardsSearch].location;
    NSScanner *scanner = [NSScanner scannerWithString:[file substringFromIndex:startxrefloc+[@"startxref" length]+1]];
    NSInteger newPrevValInt;
    [scanner scanInteger:&newPrevValInt];
    NSString *newPrevVal = [NSString stringWithFormat:@"%u",(unsigned int)newPrevValInt];
    NSString *newTrailer = nil;
    if (trailerloc!=NSNotFound) {
        NSString *trailer = [file substringWithRange:NSMakeRange(trailerloc+[@"trailer" length]+1, startxrefloc-trailerloc-1-[@"trailer" length]-1)];
        if ([trailer rangeOfString:@"/Prev"].location != NSNotFound) {
            NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"/Prev [0-9]*" options:0 error:NULL];
            newTrailer = [reg stringByReplacingMatchesInString:trailer options:0 range:NSMakeRange(0, [trailer length]) withTemplate:[NSString stringWithFormat:@"/Prev %@",newPrevVal]];
        } else {
            newTrailer = [trailer stringByReplacingOccurrencesOfString:@"/Size" withString:[NSString stringWithFormat:@"/Prev %@/Size",newPrevVal]];
        }
    } else {
        NSUInteger lastRoot = [file rangeOfString:@"/XRef" options:NSBackwardsSearch].location;
        if (lastRoot != NSNotFound) {
            NSUInteger start = [file rangeOfString:@"obj" options:NSBackwardsSearch range:NSMakeRange(0, lastRoot)].location+[@"obj" length];
            NSUInteger end = [file rangeOfString:@"stream" options:0 range:NSMakeRange(start, file.length-start)].location-1;
            newTrailer = [file substringWithRange:NSMakeRange(start, end-start+1)];
            newTrailer = [newTrailer stringByReplacingOccurrencesOfString:@"/Size" withString:[NSString stringWithFormat:@"/Prev %@/Size",newPrevVal]];
        } else {
            return nil;
        }
    }
    return [[NSString stringWithFormat:@"trailer\r%@\rstartxref\r%u\r",newTrailer,(unsigned int)fo] stringByAppendingString:@"%%EOF"];
}

@end
