// PDFArray.m
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

#import "PDFUtility.h"
#import "PDFObjectParser.h"
#import "PDFArray.h"
#import "PDFDictionary.h"
#import "PDFStream.h"
#import "PDFName.h"
#import "PDFString.h"
#import "PDFNumber.h"
#import "PDFNull.h"

@interface PDFArray(PrivateGetters)
- (NSArray *)nsa;
@end

@interface PDFArray(PrivateInitializers)
- (instancetype)initWithNSArray:(NSArray *)arr representation:(NSString *)rep cgPDFArray:(CGPDFArrayRef)cgarr;
@end

@interface PDFArray(PrivateIndexedObjectQueries)
- (PDFStream *)streamAtIndex:(NSUInteger)index;
- (PDFDictionary *)dictionaryAtIndex:(NSUInteger)index;
- (PDFArray *)arrayAtIndex:(NSUInteger)index;
- (PDFString *)stringAtIndex:(NSUInteger)index;
- (PDFName *)nameAtIndex:(NSUInteger)index;
- (PDFNumber *)integerAtIndex:(NSUInteger)index;
- (PDFNumber *)realAtIndex:(NSUInteger)index;
- (PDFNumber *)booleanAtIndex:(NSUInteger)index;
- (PDFNull *)nullAtIndex:(NSUInteger)index;
- (id<PDFObject>)pdfObjectAtIndex:(NSUInteger)index;
- (CGPDFObjectType)typeAtIndex:(NSUInteger)index;
@end

@implementation PDFArray {
    NSArray *_nsa;
    NSString *_representation;
    CGPDFArrayRef _arr;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[PDFArray class]]) return NO;
    return [self isEqualToArray:object];
}

- (NSUInteger)hash {
    return [self.nsa hash];
}

#pragma mark - PDFArray

- (instancetype)initWithArray:(CGPDFArrayRef)parr {
    self = [super init];
    if (self != nil) {
        _arr = parr;
    }
    return self;
}

- (NSValue *)rect {
    if ([self.nsa count] != 4 || [[self.nsa filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) { return [evaluatedObject respondsToSelector:@selector(doubleValue)]; }]] count] != 4) return nil;
    double x0,y0,x1,y1;
    x0 = [self.nsa[0] doubleValue];
    y0 = [self.nsa[1] doubleValue];
    x1 = [self.nsa[2] doubleValue];
    y1 = [self.nsa[3] doubleValue];
    return [NSValue valueWithCGRect:CGRectMake(MIN(x0,x1),MIN(y0,y1),fabs(x1-x0),fabs(y1-y0))];
}

- (id<PDFObject>)objectAtIndex:(NSUInteger)index {
    if (index < [self.nsa count]) return self.nsa[index];
    return nil;
}

- (NSUInteger)count {
    return [self.nsa count];
}

- (id<PDFObject>)firstObject {
    return [self.nsa firstObject];
}

- (id<PDFObject>)lastObject {
    return [self.nsa lastObject];
}

- (BOOL)isEqualToArray:(PDFArray *)otherArray {
    return [self.nsa isEqualToArray:otherArray.nsa];
}

#pragma mark - Private Getters

- (NSArray *)nsa {
    if (_nsa == nil) {
        NSMutableArray *temp = [NSMutableArray array];
        NSUInteger count = 0;
        NSMutableArray *nsaFiller = nil;
        if (_arr == NULL) {
            nsaFiller = [NSMutableArray array];
            if (_representation == nil) return nil;
            PDFObjectParser *parser = [PDFObjectParser parserWithBytes:[PDFUtility dataFromPDFString:_representation]];
            for (id pdfObject in parser) [nsaFiller addObject:pdfObject];
            count = [nsaFiller count];

        } else count = CGPDFArrayGetCount(_arr);
        
        for (NSUInteger c = 0; c < count; c++) {
            id add = (_arr != NULL ? [self pdfObjectAtIndex:c]:nsaFiller[c]);
            if (add != nil) {
                [temp addObject:add];
            }
        }
        _nsa = [NSArray arrayWithArray:temp];
    }
    return _nsa;
}

#pragma mark - Private Initializers

- (instancetype)initWithNSArray:(NSArray *)arr representation:(NSString *)rep cgPDFArray:(CGPDFArrayRef)cgarr {
    self = [self init];
    if (self != nil) {
        _nsa = arr;
        _representation = rep;
        _arr = cgarr;
    }
    return self;
}

#pragma mark - Private Indexed Object Queries

- (id)pdfObjectAtIndex:(NSUInteger)index {
    if (_arr == NULL) {
        return nil;
    }
    CGPDFObjectRef obj = NULL;
    if (CGPDFArrayGetObject(_arr,index, &obj)) {
        CGPDFObjectType type =  CGPDFObjectGetType(obj);
        switch (type) {
            case kCGPDFObjectTypeDictionary: return [self dictionaryAtIndex:index];
            case kCGPDFObjectTypeArray:      return [self arrayAtIndex:index];
            case kCGPDFObjectTypeString:     return [self stringAtIndex:index];
            case kCGPDFObjectTypeName:       return [self nameAtIndex:index];
            case kCGPDFObjectTypeInteger:    return [self integerAtIndex:index];
            case kCGPDFObjectTypeReal:       return [self realAtIndex:index];
            case kCGPDFObjectTypeBoolean:    return [self booleanAtIndex:index];
            case kCGPDFObjectTypeStream:     return [self streamAtIndex:index];
            case kCGPDFObjectTypeNull:       return [self nullAtIndex:index];
            default:
                return nil;
        }
    }
    return nil;
}

- (PDFDictionary *)dictionaryAtIndex:(NSUInteger)index {
    CGPDFDictionaryRef dr = NULL;
    if (CGPDFArrayGetDictionary(_arr, index, &dr)) {
        return [[PDFDictionary alloc] initWithDictionary:dr];
    }
    return nil;
}

- (PDFArray *)arrayAtIndex:(NSUInteger)index {
    CGPDFArrayRef ar = NULL;
    if (CGPDFArrayGetArray(_arr, index, &ar)) {
        return [[PDFArray alloc] initWithArray:ar];
    }
    return nil;
}

- (PDFString *)stringAtIndex:(NSUInteger)index {
    CGPDFStringRef str = NULL;
    if (CGPDFArrayGetString(_arr, index, &str)) {
        return [[PDFString alloc] initWithTextString:(__bridge NSString *)CGPDFStringCopyTextString(str)];
    }
    return nil;
}

- (PDFName *)nameAtIndex:(NSUInteger)index {
    const char *targ = NULL;
    if (CGPDFArrayGetName(_arr, index, &targ)) {
        return [[PDFName alloc] initWithPDFCString:targ];
    }
    return nil;
}

- (PDFNumber *)integerAtIndex:(NSUInteger)index {
    CGPDFInteger targ;
    if (CGPDFArrayGetInteger(_arr, index, &targ)) {
        return @((long)targ);
    }
    return nil;
}

- (PDFNumber *)realAtIndex:(NSUInteger)index {
    CGPDFReal targ;
    if (CGPDFArrayGetNumber(_arr, index, &targ)) {
        return @((double)targ);
    }
    return nil;
}

- (PDFNumber *)booleanAtIndex:(NSUInteger)index {
    CGPDFBoolean targ;
    if (CGPDFArrayGetBoolean(_arr, index, &targ)) {
        return @((BOOL)targ);
    }
    return nil;
}

- (PDFStream *)streamAtIndex:(NSUInteger)index {
    CGPDFStreamRef targ = NULL;
    if (CGPDFArrayGetStream(_arr, index, &targ)) {
        return [[PDFStream alloc] initWithStream:targ];
    }
    return nil;
}

- (PDFNull *)nullAtIndex:(NSUInteger)index {
    return [PDFNull null];
}

- (CGPDFObjectType)typeAtIndex:(NSUInteger)index {
    if (_arr != NULL) {
        CGPDFObjectRef obj = NULL;
        if (CGPDFArrayGetObject(_arr, index, &obj)) {
            return CGPDFObjectGetType(obj);
        }
        return kCGPDFObjectTypeNull;
    }
    return kCGPDFObjectTypeNull;
}

#pragma mark - PDFObject

- (CGPDFObjectType)type {
    return kCGPDFObjectTypeArray;
}

- (NSString *)pdfFileRepresentation {
    NSMutableString *ret = [NSMutableString stringWithString:@"["];
    for (NSUInteger i = 0; i < [self count]; i++) {
        [ret appendFormat:@" %@",[(id<PDFObject>)(self[i]) pdfFileRepresentation]];
    }
    [ret appendString:@"]"];
    return [NSString stringWithString:ret];
}

+ (instancetype)pdfObjectWithRepresentation:(NSData *)rep flags:(PDFRepOptions)flags {
    return [[PDFArray alloc] initWithNSArray:nil representation:[PDFUtility trimmedStringFromPDFData:rep] cgPDFArray:NULL];
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.nsa countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    NSArray *copiedArray = [self.nsa copyWithZone:zone];
    NSString *copiedRep = [_representation copyWithZone:zone];
    return [[[self class] allocWithZone:zone] initWithNSArray:copiedArray representation:copiedRep cgPDFArray:_arr];
}

#pragma mark - Indexed Subscripting

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:idx];
}

@end
