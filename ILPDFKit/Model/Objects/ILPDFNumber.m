// ILPDFNumber.m
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

#import "ILPDFNumber.h"
#import "ILPDFUtility.h"

@implementation ILPDFNumber(ILPDFObject)

#pragma mark - ILPDFObject

- (CGPDFObjectType)type {
    if (strcmp([self objCType], @encode(BOOL)) == 0) return kCGPDFObjectTypeBoolean;
    if (strcmp([self objCType], @encode(unsigned char)) == 0) return kCGPDFObjectTypeBoolean;
    if (strcmp([self objCType], @encode(char)) == 0) return kCGPDFObjectTypeBoolean;
    if (strcmp([self objCType], @encode(float)) == 0) return kCGPDFObjectTypeReal;
    if (strcmp([self objCType], @encode(double)) == 0) return kCGPDFObjectTypeReal;
    return kCGPDFObjectTypeInteger;
}

- (NSString *)pdfFileRepresentation {
    if ([self type] == kCGPDFObjectTypeBoolean) {
        if ([self boolValue])return @"true";
        return @"false";
    }
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    f.usesGroupingSeparator = NO;
    if ([self type] == kCGPDFObjectTypeReal) {
        f.alwaysShowsDecimalSeparator = YES;
    }
    return [f stringFromNumber:self];
}

+ (instancetype)pdfObjectWithRepresentation:(NSData *)rep flags:(ILPDFRepOptions)flags {
    NSString *work = [ILPDFUtility trimmedStringFromPDFData:rep];
    if ([work rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"0987654321+-."] invertedSet]].location == NSNotFound) {
        if ([work rangeOfString:@"."].location != NSNotFound) return @(atof([work UTF8String]));
        return @(atoll([work UTF8String]));
    }
    if ([work isEqualToString:@"true"]) return @YES;
    if ([work isEqualToString:@"false"]) return @NO;
    return nil;
}


@end
