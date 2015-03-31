// PDFObjectParser.m
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

#import "PDF.h"
#import "PDFObjectParser.h"

typedef struct {
    NSUInteger index;
    NSUInteger nestCount;
    NSUInteger startOfScanIndex;
} PDFObjectParserState;

@interface PDFObjectParser()
- (id<PDFObject>)pdfObjectFromString:(NSString *)st;
- (id<PDFObject>)parseNextElement:(PDFObjectParserState *)state;
@end

@implementation PDFObjectParser {
    NSString *_str;
}

#pragma mark - Initialization

+ (PDFObjectParser *)parserWithBytes:(NSData *)bytes {
    return [[PDFObjectParser alloc] initWithBytes:bytes];
}

- (instancetype)initWithBytes:(NSData *)bytes {
    self = [super init];
    if (self != nil) {
        NSString *strg = [PDFUtility trimmedStringFromPDFData:bytes];
        if ([strg characterAtIndex:0] == '<') {
            _str = [strg substringWithRange:NSMakeRange(1, strg.length-2)] ;
        } else _str = strg;
        
        if (_str) {
            //Here we replace indirect object references with a representation that is more easily parsed on the next step.
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(\\d+)\\s+(\\d+)\\s+[R](\\W)" options:0 error:NULL];
            _str = [regex stringByReplacingMatchesInString:_str options:0 range:NSMakeRange(0, _str.length) withTemplate:@"($1,$2,ioref)$3"];
        }
    }
    return self;
}

#pragma mark - Parsing

- (id<PDFObject>)parseNextElement:(PDFObjectParserState *)state {
    NSUInteger index = state -> index;
    NSUInteger nestCount = state -> nestCount;
    NSUInteger startOfScanIndex = state -> startOfScanIndex;
    id<PDFObject> __strong ret = nil;
    while (index < _str.length) {
        NSRange range = {0,0};
        unichar cur = [_str characterAtIndex:index];
        BOOL found = NO;
        BOOL ws = isWS(cur);
        BOOL odl = isODelim(cur);
        BOOL cdl = isCDelim(cur);
        BOOL dl = isDelim(cur);
        if (odl) nestCount++;
        if (cdl) nestCount--;
        if (startOfScanIndex == 0) {
            if (!ws && (nestCount-odl) == 1) startOfScanIndex = index;
        } else {
            range.location = startOfScanIndex;
            range.length = index - startOfScanIndex;
            found = YES;
            if (nestCount == 1 && (ws||cdl)) {
                startOfScanIndex = 0;
                range.length += cdl;
            } else if (((nestCount <= 1) && dl)||(nestCount == 2 && odl)) {
                startOfScanIndex = index; 
            } else found = NO;
        }
        index++;
        if (found) {
            ret =  [self pdfObjectFromString:[_str substringWithRange:range]];
            break;
        }
    }
    state->index = index;
    state->nestCount = nestCount;
    state->startOfScanIndex = startOfScanIndex;
    return ret;
}

// The string passed musn't include an indirect object definition header. eg ' 7 0 obj '

- (id<PDFObject>)pdfObjectFromString:(NSString *)st {
    id<PDFObject> obj = nil;
    NSData *rep = [PDFUtility dataFromPDFString:st];
    if ((obj = [PDFString pdfObjectWithRepresentation:rep flags:PDFRepOptionNone])) {
        return obj;
    }
    if ((obj = [PDFName pdfObjectWithRepresentation:rep flags:PDFRepOptionNone])) {
        return obj;
    }
    if ((obj = [PDFNumber pdfObjectWithRepresentation:rep flags:PDFRepOptionNone])) {
        return obj;
    }
    if ((obj = [PDFDictionary pdfObjectWithRepresentation:rep flags:PDFRepOptionNone])) {
        return obj;
    }
    if ((obj = [PDFArray pdfObjectWithRepresentation:rep flags:PDFRepOptionNone])) {
        return obj;
    }
    if ((obj = [PDFStream pdfObjectWithRepresentation:rep flags:PDFRepOptionNone])) {
        return obj;
    }
    if ((obj = [PDFNull pdfObjectWithRepresentation:rep flags:PDFRepOptionNone])) {
        return obj;
    }
    return nil;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len {
    PDFObjectParserState parserState;
    if (state->state == 0) {
        parserState.index = 0;
        parserState.nestCount = 0;
        parserState.startOfScanIndex = 0;
    } else {
        parserState.index = (NSUInteger)(state->state);
        parserState.nestCount = (NSUInteger)((state->extra)[0]);
        parserState.startOfScanIndex = (NSUInteger)((state->extra)[1]);
    }
    NSUInteger batchCount = 0;
    while (parserState.index < _str.length && batchCount < len) {
        __autoreleasing id obj = [self parseNextElement:&parserState];
        if (obj) {
            stackbuf[batchCount] = obj;
            batchCount++;
        }
    }
    state->state = (unsigned long)parserState.index;
    ((state->extra)[0]) = (unsigned long)parserState.nestCount;
    ((state->extra)[1]) = (unsigned long)parserState.startOfScanIndex;
    state->itemsPtr = stackbuf;
    state->mutationsPtr = (__bridge void *)_str;
    return batchCount;
}

@end
