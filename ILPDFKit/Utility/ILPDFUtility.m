// ILPDFUtility.m
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

@implementation ILPDFUtility

#pragma mark - Utility Functions

+ (CGContextRef)outputPDFContextCreate:(const CGRect *)inMediaBox path:(CFStringRef)path {
    CGContextRef outContext = NULL;
    CFURLRef url;
    url = CFURLCreateWithFileSystemPath(NULL,path,kCFURLPOSIXPathStyle,false);
    if (url != NULL) {
        outContext = CGPDFContextCreateWithURL(url,inMediaBox,NULL);
        CFRelease(url);
        
    }
    return outContext;
}

+ (CGPDFDocumentRef)createPDFDocumentRefFromData:(NSData *)data {
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(dataProvider);
    CGDataProviderRelease(dataProvider);
    return pdf;
}

+ (CGPDFDocumentRef)createPDFDocumentRefFromResource:(NSString *)name {
    NSString *pathToPdfDoc = [[NSBundle mainBundle] pathForResource:name ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:pathToPdfDoc];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    return pdf;
}

+ (CGPDFDocumentRef)createPDFDocumentRefFromPath:(NSString *)pathToPdfDoc {
    NSURL *url = [NSURL fileURLWithPath:pathToPdfDoc];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    return pdf;
}


#pragma mark - Character Sets and Encodings


+ (NSCharacterSet *)whiteSpaceCharacterSet {
    NSMutableCharacterSet *ret = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(0, 1)];
    for (NSNumber *index in [ILPDFUtility whiteSpaceCharacterCodes]) {
        [ret addCharactersInRange:NSMakeRange([index unsignedCharValue], 1)];
    }
    return ret;
}

+ (NSString *)stringByRemovingWhiteSpaceFrom:(NSString *)str {
    NSString *result = [NSString stringWithString:str];
    for (NSNumber *index in [ILPDFUtility whiteSpaceCharacterCodes]) {
        result = [result stringByReplacingCharactersInRange:NSMakeRange([index unsignedCharValue], 1) withString:@""];
    }
    return result;
}

+ (NSCharacterSet *)delimeterCharacterSet {
    NSMutableCharacterSet *ret = [[NSMutableCharacterSet alloc] init];
    for (NSNumber *code in [ILPDFUtility delimiterCharacterCodes]) [ret addCharactersInRange:NSMakeRange([code unsignedCharValue], 1)];
    return ret;
}

+ (NSString *)encodeStringForXML:(NSString *)str {
    if (![str isKindOfClass:[NSString class]])return nil;
    return [[str stringByReplacingOccurrencesOfString:@"<" withString:@"&#60;"] stringByReplacingOccurrencesOfString:@">" withString:@"&#62;"] ;
}

+ (NSArray *)delimiterCharacterCodes {
    return  @[@0x25,@0x28,@0x29,@0x5B,@0x5D,@0x7B,@0x7D,@0x3C,@0x3E,@0x2F];
}

+ (NSArray *)whiteSpaceCharacterCodes {
    return @[@0x09,@0x0A,@0x0C,@0x0D,@0x20];
}

+ (NSString *)trimmedStringFromPDFData:(NSData *)data {
    NSString *ret = [[NSString alloc] initWithData:data encoding:ILPDFStringCharacterEncoding];
    ret = [ret stringByTrimmingCharactersInSet:[ILPDFUtility whiteSpaceCharacterSet]];
    return ret;
}

+ (NSString *)stringFromPDFData:(NSData *)data {
    NSString *ret = [[NSString alloc] initWithData:data encoding:ILPDFStringCharacterEncoding];
    return ret;
}

+ (NSData *)dataFromPDFString:(NSString *)str {
    return [str dataUsingEncoding:ILPDFStringCharacterEncoding];
}

+ (NSString *)stringFromPDFCString:(const char *)str {
    return [NSString stringWithCString:str encoding:ILPDFStringCharacterEncoding];
}

+ (const char *)cStringFromPDFString:(NSString *)str {
    return [str cStringUsingEncoding:ILPDFStringCharacterEncoding];
}


@end
