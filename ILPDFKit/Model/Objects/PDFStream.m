// PDFStream.m
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

#import "PDFStream.h"
#import "PDFString.h"
#import "PDFDictionary.h"
#import "PDFUtility.h"

@interface PDFStream(PrivateInitializers)
- (instancetype)initWithStreamRef:(CGPDFStreamRef)strm data:(NSData *)data dictionary:(PDFDictionary *)dict format:(CGPDFDataFormat)format representation:(NSString *)representation;
@end

@implementation PDFStream {
    NSData *_data;
    PDFDictionary *_dictionary;
    CGPDFDataFormat _dataFormat;
    NSString *_representation;
    CGPDFStreamRef _strm;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[PDFStream class]]) return NO;
    return [self isEqualToStream:object];
}

- (NSUInteger)hash {
    return [self.dictionary hash] ^ [self.data hash];
}

#pragma mark - PDFStream

- (instancetype)initWithStream:(CGPDFStreamRef)pstrm {
    self = [super init];
    if (self != nil) {
        _strm = pstrm;
    }
    return self;
}

- (PDFDictionary *)dictionary {
    if (_dictionary == nil) {
        CGPDFDictionaryRef dict = CGPDFStreamGetDictionary(_strm);
        if (dict) {
            _dictionary = [[PDFDictionary alloc] initWithDictionary:dict];
        }
    }
    return _dictionary;
}

- (CGPDFDataFormat)dataFormat {
    if (_data == nil) {
        NSData *temp = self.data;
        temp = nil;
    }
    return _dataFormat;
}

- (NSData *)data {
    if (_data == nil) {
        CFDataRef dat = CGPDFStreamCopyData(_strm, &_dataFormat);
        _data = ((__bridge NSData*)dat);
        CFRelease(dat);
    }
    return _data;
}

- (BOOL)isEqualToStream:(PDFStream *)otherStream {
    return [self.data isEqualToData:otherStream.data] && self.dataFormat == otherStream.dataFormat && [self.dictionary isEqualToDictionary:otherStream.dictionary];
}

#pragma mark - Private Initializers

- (instancetype)initWithStreamRef:(CGPDFStreamRef)strm data:(NSData *)data dictionary:(PDFDictionary *)dict format:(CGPDFDataFormat)format representation:(NSString *)representation {
    self = [self init];
    if (self != nil) {
        _strm = strm;
        _data = data;
        _dictionary = dict;
        _dataFormat = format;
        _representation = representation;
    }
    return self;
}

#pragma mark - PDFObject

- (CGPDFObjectType)type {
    return kCGPDFObjectTypeStream;
}

- (NSString *)pdfFileRepresentation {
    NSString *dataString = [PDFUtility stringFromPDFData:self.data];
    return [NSString stringWithFormat:@"%@\nstream\n%@\nendstream",[self.dictionary pdfFileRepresentation],dataString];
}

+ (instancetype)pdfObjectWithRepresentation:(NSData *)rep flags:(PDFRepOptions)flags {
    NSString *work = [PDFUtility trimmedStringFromPDFData:rep];
    NSString *headerPart = [work substringToIndex:[work rangeOfString:@"stream"].location];
    PDFDictionary *header = [PDFDictionary pdfObjectWithRepresentation:[PDFUtility dataFromPDFString:headerPart] flags:PDFRepOptionNone];
    NSInteger length = [header[@"Length"] integerValue];
    NSUInteger start;
    if ([work rangeOfString:@"stream\r\n"].location != NSNotFound) start = [work rangeOfString:@"stream\r\n"].location + @"stream\r\n".length;
    else start = [work rangeOfString:@"stream\n"].location + @"stream\n".length;
    NSString *dataString = [work substringWithRange:NSMakeRange(start, length)];
    return [[PDFStream alloc] initWithStreamRef:NULL data:[PDFUtility dataFromPDFString:dataString] dictionary:header format:CGPDFDataFormatRaw representation:work];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    NSData *copiedData = [self.data copyWithZone:zone];
    PDFDictionary *copiedHeader = [self.dictionary copyWithZone:zone];
    NSString *copiedRep = [_representation copyWithZone:zone];
    return [[[self class] allocWithZone:zone] initWithStreamRef:_strm data:copiedData dictionary:copiedHeader format:_dataFormat representation:copiedRep];
}

@end
