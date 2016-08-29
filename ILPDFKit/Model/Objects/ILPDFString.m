// ILPDFString.m
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

#import "ILPDFString.h"
#import "ILPDFUtility.h"

@interface NSData(HexString)
-(NSString *)hexadecimalString;
@end

@implementation ILPDFString(ILPDFObject)

#pragma mark - ILPDFString

- (NSString *)utf8TextString {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

- (NSString *)hexStringRepresentation {
    return [NSString stringWithFormat:@"<%@>",[self hexadecimalString]];
}

- (NSString *)textString {
    return [ILPDFUtility stringFromPDFData:self];
}

- (instancetype)initWithTextString:(NSString *)str {
    return [self initWithData:[ILPDFUtility dataFromPDFString:str]];
}

#pragma mark - ILPDFObject

- (CGPDFObjectType)type {
    return kCGPDFObjectTypeString;
}

- (NSString *)pdfFileRepresentation {
    NSString *start = [self textString];
    NSMutableString *ret = [NSMutableString stringWithString:@""];
    for (NSUInteger i = 0; i < start.length; i++) {
        unsigned char c = [start characterAtIndex:i];
        if (c < 128) [ret appendFormat:@"%c",c];
        else [ret appendFormat:@"\\%.3o",c];
    }
    return [NSString stringWithFormat:@"(%@)",ret];
}

+ (instancetype)pdfObjectWithRepresentation:(NSData *)rep flags:(ILPDFRepOptions)flags {
    NSString *work = [ILPDFUtility trimmedStringFromPDFData:rep];
    if ([work characterAtIndex:0] == '(' && [work characterAtIndex:work.length-1] == ')') {
        return [ILPDFUtility dataFromPDFString:[work substringWithRange:NSMakeRange(1, work.length-2)]];
    }
    if ([work characterAtIndex:0] == '<' && [work characterAtIndex:work.length-1] == '>' && [work characterAtIndex:1] != '<') {
        NSString *bytes = [ILPDFUtility stringByRemovingWhiteSpaceFrom:[work substringWithRange:NSMakeRange(1, work.length-2)]];
        if (bytes.length % 2 == 1) bytes = [bytes stringByAppendingString:@"0"];
        NSMutableData *data = [[NSMutableData alloc] init];
        unsigned char whole_byte;
        char byte_chars[3] = {'\0','\0','\0'};
        for (NSUInteger i = 0; i < ([bytes length] / 2); i++) {
            byte_chars[0] = [bytes characterAtIndex:i*2];
            byte_chars[1] = [bytes characterAtIndex:i*2+1];
            whole_byte = strtol(byte_chars, NULL, 16);
            [data appendBytes:&whole_byte length:1];
        }
        return  [[ILPDFString alloc] initWithData:data];
    }
    return nil;
}

@end

@implementation NSData(HexString)
- (NSString *)hexadecimalString {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    if (!dataBuffer) return [NSString string];
    NSUInteger dataLength  = [self length];
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (NSUInteger i = 0; i < dataLength; ++i) [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    return [NSString stringWithString:hexString];
}
@end
