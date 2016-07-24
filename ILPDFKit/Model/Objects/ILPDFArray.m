// ILPDFArray.m
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

#import "ILPDFUtility.h"
#import "ILPDFObjectParser.h"
#import "ILPDFArray.h"
#import "ILPDFDictionary.h"
#import "ILPDFStream.h"
#import "ILPDFName.h"
#import "ILPDFString.h"
#import "ILPDFNumber.h"
#import "ILPDFNull.h"
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ILPDFArray(PrivateGetters)
- (NSArray *)nsa;
@end

@interface ILPDFArray(PrivateInitializers)
- (instancetype)initWithNSArray:(NSArray *)arr representation:(NSString *)rep cgPDFArray:(CGPDFArrayRef)cgarr;
@end

@interface ILPDFArray(PrivateIndexedObjectQueries)
- (ILPDFStream *)streamAtIndex:(NSUInteger)index;
- (ILPDFDictionary *)dictionaryAtIndex:(NSUInteger)index;
- (ILPDFArray *)arrayAtIndex:(NSUInteger)index;
- (ILPDFString *)stringAtIndex:(NSUInteger)index;
- (ILPDFName *)nameAtIndex:(NSUInteger)index;
- (ILPDFNumber *)integerAtIndex:(NSUInteger)index;
- (ILPDFNumber *)realAtIndex:(NSUInteger)index;
- (ILPDFNumber *)booleanAtIndex:(NSUInteger)index;
- (ILPDFNull *)nullAtIndex:(NSUInteger)index;
- (id<ILPDFObject>)pdfObjectAtIndex:(NSUInteger)index;
- (CGPDFObjectType)typeAtIndex:(NSUInteger)index;
@end

@implementation ILPDFArray {
    NSArray *_nsa;
    NSString *_representation;
    CGPDFArrayRef _arr;
}

#pragma mark - NSObject

- (id)init {
    void  *arr = NULL;
    self = [self initWithArray:arr];
    return self;
}


- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[ILPDFArray class]]) return NO;
    return [self isEqualToArray:object];
}

- (NSUInteger)hash {
    return [self.nsa hash];
}

#pragma mark - ILPDFArray

- (instancetype)initWithArray:(CGPDFArrayRef)parr {
    NSParameterAssert(parr);
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

- (id<ILPDFObject>)objectAtIndex:(NSUInteger)index {
    if (index < [self.nsa count]) return self.nsa[index];
    return nil;
}

- (NSUInteger)count {
    return [self.nsa count];
}

- (id<ILPDFObject>)firstObject {
    return [self.nsa firstObject];
}

- (id<ILPDFObject>)lastObject {
    return [self.nsa lastObject];
}

- (BOOL)isEqualToArray:(ILPDFArray *)otherArray {
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
            ILPDFObjectParser *parser = [ILPDFObjectParser parserWithBytes:[ILPDFUtility dataFromPDFString:_representation]];
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

- (ILPDFDictionary *)dictionaryAtIndex:(NSUInteger)index {
    CGPDFDictionaryRef dr = NULL;
    if (CGPDFArrayGetDictionary(_arr, index, &dr)) {
        return [[ILPDFDictionary alloc] initWithDictionary:dr];
    }
    return nil;
}

- (ILPDFArray *)arrayAtIndex:(NSUInteger)index {
    CGPDFArrayRef ar = NULL;
    if (CGPDFArrayGetArray(_arr, index, &ar)) {
        return [[ILPDFArray alloc] initWithArray:ar];
    }
    return nil;
}

- (ILPDFString *)stringAtIndex:(NSUInteger)index {
    CGPDFStringRef str = NULL;
    if (CGPDFArrayGetString(_arr, index, &str)) {
        return [[ILPDFString alloc] initWithTextString:(__bridge NSString *)CGPDFStringCopyTextString(str)];
    }
    return nil;
}

- (ILPDFName *)nameAtIndex:(NSUInteger)index {
    const char *targ = NULL;
    if (CGPDFArrayGetName(_arr, index, &targ)) {
        return [[ILPDFName alloc] initWithPDFCString:targ];
    }
    return nil;
}

- (ILPDFNumber *)integerAtIndex:(NSUInteger)index {
    CGPDFInteger targ;
    if (CGPDFArrayGetInteger(_arr, index, &targ)) {
        return @((long)targ);
    }
    return nil;
}

- (ILPDFNumber *)realAtIndex:(NSUInteger)index {
    CGPDFReal targ;
    if (CGPDFArrayGetNumber(_arr, index, &targ)) {
        return @((double)targ);
    }
    return nil;
}

- (ILPDFNumber *)booleanAtIndex:(NSUInteger)index {
    CGPDFBoolean targ;
    if (CGPDFArrayGetBoolean(_arr, index, &targ)) {
        return @((BOOL)targ);
    }
    return nil;
}

- (ILPDFStream *)streamAtIndex:(NSUInteger)index {
    CGPDFStreamRef targ = NULL;
    if (CGPDFArrayGetStream(_arr, index, &targ)) {
        return [[ILPDFStream alloc] initWithStream:targ];
    }
    return nil;
}

- (ILPDFNull *)nullAtIndex:(NSUInteger)index {
    return [ILPDFNull null];
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

#pragma mark - ILPDFObject

- (CGPDFObjectType)type {
    return kCGPDFObjectTypeArray;
}

- (NSString *)pdfFileRepresentation {
    NSMutableString *ret = [NSMutableString stringWithString:@"["];
    for (NSUInteger i = 0; i < [self count]; i++) {
        [ret appendFormat:@" %@",[(id<ILPDFObject>)(self[i]) pdfFileRepresentation]];
    }
    [ret appendString:@"]"];
    return [NSString stringWithString:ret];
}

+ (instancetype)pdfObjectWithRepresentation:(NSData *)rep flags:(ILPDFRepOptions)flags {
    return [[ILPDFArray alloc] initWithNSArray:nil representation:[ILPDFUtility trimmedStringFromPDFData:rep] cgPDFArray:NULL];
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
