// PDFName.m
// 
// Copyright (c) 2015 Iwe Labs
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

#import "PDFName.h"
#import "PDF.h"

@interface PDFName(HashEncoding)
- (PDFName *)hashEncodedName;
- (NSData *)hashDecodedData;
@end

@implementation PDFName(HashEncoding)

- (PDFName *)hashEncodedName {
    NSMutableString *str = [self mutableCopy];
    // First espace the literal hashes so there's no ambiguity. '#' = 0x23 in ASCII
    [str replaceCharactersInRange:NSMakeRange(0x23, 1) withString:@"#23"];
    NSMutableIndexSet *bytesToEscape = [NSMutableIndexSet indexSet];
    [bytesToEscape addIndexesInRange:NSMakeRange(0x1, 0x20)];
    [bytesToEscape addIndexesInRange:NSMakeRange(0x7F, 0xFF-0x7F+0x1)];
    for (NSNumber *index in [PDFUtility delimiterCharacterCodes]) [bytesToEscape addIndex:[index unsignedCharValue]];
    [bytesToEscape enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [str replaceCharactersInRange:NSMakeRange(idx, 1) withString:[NSString stringWithFormat:@"#%.2X",(unsigned)idx]];
        
    }];
    return [PDFName stringWithString:str];
}

- (NSData *)hashDecodedData {
    NSMutableString *str = [self mutableCopy];
    NSMutableIndexSet *bytesToEscape = [NSMutableIndexSet indexSet];
    [bytesToEscape addIndexesInRange:NSMakeRange(0x1, 0x20)];
    [bytesToEscape addIndexesInRange:NSMakeRange(0x7F, 0xFF-0x7F+0x1)];
    for (NSNumber *index in [PDFUtility delimiterCharacterCodes]) [bytesToEscape addIndex:[index unsignedCharValue]];
    [bytesToEscape enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        char cstr[2];
        cstr[0] = (char)idx;
        cstr[1] = 0;
        [str replaceOccurrencesOfString:[NSString stringWithFormat:@"#%.2X",(unsigned)idx] withString:[PDFUtility stringFromPDFCString:(const char*)cstr] options:0 range:NSMakeRange(0, str.length)];
    }];
    [str replaceOccurrencesOfString:@"#23" withString:@"#" options:0 range:NSMakeRange(0, str.length)];
    return [PDFUtility dataFromPDFString:str];
}

@end

@implementation PDFName(PDFObject)

#pragma mark - PDFName

- (const char *)pdfCString {
    return [PDFUtility cStringFromPDFString:self];
}

- (instancetype)initWithPDFCString:(const char *)cString {
    return [self initWithCString:cString encoding:PDFStringCharacterEncoding];
}

- (NSString *)utf8DecodedString {
    return [[NSString alloc] initWithData:[self hashDecodedData] encoding:NSUTF8StringEncoding];
}

#pragma mark - PDFObject

- (CGPDFObjectType)type {
    return kCGPDFObjectTypeName;
}

- (NSString *)pdfFileRepresentation {
    return [NSString stringWithFormat:@"/%@",[self hashEncodedName]];
}

+ (instancetype)pdfObjectWithRepresentation:(NSData *)rep flags:(PDFRepOptions)flags {
    NSString *work = [PDFUtility trimmedStringFromPDFData:rep];
    if ([work characterAtIndex:0] == '/') {
        return [PDFUtility stringFromPDFData:[[work substringWithRange:NSMakeRange(1, work.length-1)] hashDecodedData]];
    }
    return nil;
}

@end
