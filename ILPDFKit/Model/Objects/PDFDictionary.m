// PDFDictionary.m
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
#import "PDFString.h"
#import "PDFNumber.h"
#import "PDFNull.h"


@interface PDFDictionary(PrivateGetters)
- (NSDictionary *)nsd;
@end

@interface PDFDictionary(PrivateInitializers)
- (instancetype)initWithNSDictionary:(NSDictionary *)dict representation:(NSString *)rep cgPDFDictionary:(CGPDFDictionaryRef)cgdict parent:(PDFDictionary *)parent;
@end

@interface PDFDictionary(PrivateIndexedObjectQueries)
- (id<PDFObject>)pdfObjectFromKey:(PDFName *)key;
- (PDFDictionary *)dictionaryFromKey:(PDFName *)key;
- (PDFArray *)arrayFromKey:(PDFName *)key;
- (PDFString *)stringFromKey:(PDFName *)key;
- (PDFName *)nameFromKey:(PDFName *)key;
- (PDFNumber *)integerFromKey:(PDFName *)key;
- (PDFNumber *)realFromKey:(PDFName *)key;
- (PDFNumber *)booleanFromKey:(PDFName *)key;
- (PDFStream *)streamFromKey:(PDFName *)key;
- (PDFNull *)nullFromKey:(PDFName *)key;
- (CGPDFObjectType)typeForKey:(PDFName *)key;
@end

@implementation PDFDictionary {
    NSDictionary *_nsd;
    NSString *_representation;
    CGPDFDictionaryRef _dict;
}

void checkKeys(const char *key,CGPDFObjectRef value,void *info) {
    PDFName *nameToAdd = [[PDFName alloc] initWithPDFCString:key];
    [(__bridge NSMutableArray *)info addObject:nameToAdd];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (object == self) return  YES;
    if (![object isKindOfClass:[PDFDictionary class]]) return NO;
    return [self isEqualToDictionary:object];
}

- (NSUInteger)hash {
    return [self.nsd hash];
}

#pragma mark - PDFDictionary

- (instancetype)initWithDictionary:(CGPDFDictionaryRef)pdict {
    self = [super init];
    if (self != nil) {
        _dict = pdict;
    }
    return self;
}

- (PDFDictionary *)dictionaryByMergingDictionary:(NSDictionary *)changes {
    NSMutableDictionary *temp = [self.nsd mutableCopy];
    for (PDFName *key in changes) {
        temp[key] = changes[key];
    }
    return [[PDFDictionary alloc] initWithNSDictionary:[NSDictionary dictionaryWithDictionary:temp] representation:nil cgPDFDictionary:NULL parent:nil];
}

- (id<PDFObject>)objectForKey:(PDFName *)aKey {
    return self.nsd[aKey];
}

- (NSArray *)allKeys {
    return [self.nsd allKeys];
}

- (NSArray *)allValues {
    return [self.nsd allValues];
}

- (id<PDFObject>)inheritableValueForKey:(PDFName *)key {
    PDFDictionary *iter = nil;
    NSMutableArray *chain = [NSMutableArray array];
    for (iter = self; iter && iter[key] == nil; iter = iter.parent) {
        // If we have a cycle, break.
        if ([chain containsObject:iter]) break;
        [chain addObject:iter];
    }
    return iter[key];
}

- (NSArray *)parentValuesForKey:(PDFName *)key {
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *chain = [NSMutableArray array];
    for (PDFDictionary *iter = self; iter; iter = iter.parent) {
        // If we have a cycle, break.
        if ([chain containsObject:iter]) break;
        [chain addObject:iter];
        if (iter[key]) [result addObject:iter[key]];
    }
    return [NSArray arrayWithArray:result];;
}

- (BOOL)isEqualToDictionary:(PDFDictionary *)otherDictionary {
    return [self.nsd isEqualToDictionary:otherDictionary.nsd];
}

- (NSUInteger)count {
    return [self.nsd count];
}

- (PDFDictionary *)parent {
    if (!_parent) {
        _parent = self[@"Parent"];
    }
    return _parent;
}

#pragma mark - Private Getters

- (NSDictionary *)nsd {
    if (_nsd == nil) {
       NSMutableArray *keys = [NSMutableArray array];
       NSMutableDictionary *nsdFiller = nil;
       if (_dict != NULL) {
            CGPDFDictionaryApplyFunction(_dict, checkKeys, (__bridge void *)(keys));
       } else {
            nsdFiller = [NSMutableDictionary dictionary];
            NSMutableArray *keysAndValues = [[NSMutableArray alloc] init];
            if (_representation == nil) return nil;
            PDFObjectParser *parser = [PDFObjectParser parserWithBytes:[PDFUtility dataFromPDFString:_representation]];
            for (id pdfObject in parser) {
                [keysAndValues addObject:pdfObject];
            }
            if ([keysAndValues count]&1)return nil;
            for (NSUInteger c = 0; c < [keysAndValues count]/2; c++) {
                PDFName *key = keysAndValues[2*c];
                [keys addObject:key];
                nsdFiller[key] = keysAndValues[2*c+1];
            }
        }

        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        for (PDFName *key in keys) {
           id set = (_dict != NULL ? [self pdfObjectFromKey:key]:nsdFiller[key]);
           if (set != nil) {
              if ([set isKindOfClass:[PDFDictionary class]]) {
                    [set setParent:self];
              }
              temp[key] = set;
           }
        }
        _nsd = [NSDictionary  dictionaryWithDictionary:temp];
    }
    return _nsd;
}

#pragma mark - Private Initializers

- (instancetype)initWithNSDictionary:(NSDictionary *)dict representation:(NSString *)rep cgPDFDictionary:(CGPDFDictionaryRef)cgdict parent:(PDFDictionary *)parent {
    self = [self init];
    if (self != nil) {
        _nsd = dict;
        _representation = rep;
        _dict = cgdict;
        _parent = parent;
    }
    return self;
}

#pragma mark - Private Indexed Object Queries

- (id<PDFObject>)pdfObjectFromKey:(PDFName *)key {
    CGPDFObjectRef obj = NULL;
    if (CGPDFDictionaryGetObject(_dict, [key pdfCString], &obj)) {
        CGPDFObjectType type =  CGPDFObjectGetType(obj);
        switch (type) {
            case kCGPDFObjectTypeDictionary: return [self dictionaryFromKey:key];
            case kCGPDFObjectTypeArray:      return [self arrayFromKey:key];
            case kCGPDFObjectTypeString:     return [self stringFromKey:key];
            case kCGPDFObjectTypeName:       return [self nameFromKey:key];
            case kCGPDFObjectTypeInteger:    return [self integerFromKey:key];
            case kCGPDFObjectTypeReal:       return [self realFromKey:key];
            case kCGPDFObjectTypeBoolean:    return [self booleanFromKey:key];
            case kCGPDFObjectTypeStream:     return [self streamFromKey:key];
            case kCGPDFObjectTypeNull:       return [self nullFromKey:key];
            default:
                return nil;
        }
    }
    return nil;
}

- (PDFDictionary *)dictionaryFromKey:(PDFName *)key {
    CGPDFDictionaryRef dr = NULL;
    if (CGPDFDictionaryGetDictionary(_dict,[key pdfCString], &dr)) {
        return [[PDFDictionary alloc] initWithDictionary:dr];
    }
    return nil;
}

- (PDFArray *)arrayFromKey:(PDFName *)key {
    CGPDFArrayRef ar = NULL;
    if (CGPDFDictionaryGetArray(_dict,[key pdfCString], &ar)) {
        return [[PDFArray alloc] initWithArray:ar];
    }
    return nil;
}

- (PDFString *)stringFromKey:(PDFName *)key {
    CGPDFStringRef str = NULL;
    if (CGPDFDictionaryGetString(_dict,[key pdfCString], &str)) {
        return [[PDFString alloc] initWithTextString:(__bridge NSString *)CGPDFStringCopyTextString(str)];
    }
    return nil;
}

- (PDFName *)nameFromKey:(PDFName *)key {
    const char* targ = NULL;
    if (CGPDFDictionaryGetName(_dict,[key pdfCString], &targ))  {
        return [[PDFName alloc] initWithPDFCString:targ];
    }
    return nil;
}

- (PDFNumber *)integerFromKey:(PDFName *)key {
    CGPDFInteger targ;
    if (CGPDFDictionaryGetInteger(_dict,[key pdfCString], &targ)) {
        return @((long)targ);
    }
    return nil;
}

- (PDFNumber *)realFromKey:(PDFName *)key {
    CGPDFReal targ;
    if (CGPDFDictionaryGetNumber(_dict,[key pdfCString], &targ)) {
        return @((double)targ);
    }
    return nil;
}


- (PDFNumber *)booleanFromKey:(PDFName *)key {
    CGPDFBoolean targ;
    if (CGPDFDictionaryGetBoolean(_dict,[key pdfCString], &targ)) {
        return @((BOOL)targ);
    }
    return nil;
}

- (PDFStream *)streamFromKey:(PDFName *)key {
    CGPDFStreamRef targ = NULL;
    if (CGPDFDictionaryGetStream(_dict,[key pdfCString], &targ)) {
        return [[PDFStream alloc] initWithStream:targ];
    }
    return nil;
}

- (PDFNull *)nullFromKey:(PDFName *)key {
    return [PDFNull null];
}

- (CGPDFObjectType)typeForKey:(PDFName *)key {
    if (_dict != NULL) {
        CGPDFObjectRef obj = NULL;
        if (CGPDFDictionaryGetObject(_dict,[key pdfCString], &obj)) {
            return CGPDFObjectGetType(obj);
        }
        return kCGPDFObjectTypeName;
    }
    return kCGPDFObjectTypeNull;
}


#pragma mark - PDFObject

- (CGPDFObjectType)type {
    return kCGPDFObjectTypeDictionary;
}

- (NSString *)pdfFileRepresentation {
    NSArray *keys = [self allKeys];
    NSMutableString *ret = [NSMutableString stringWithString:@"<<\n"];
    for (NSUInteger i = 0; i < [keys count]; i++) {
        PDFName *key = keys[i];
        id<PDFObject> obj = self[key];
        [ret appendString:[NSString stringWithFormat:@"%@ %@\n",[key pdfFileRepresentation],[obj pdfFileRepresentation]]];
    }
    [ret appendString:@">>"];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\((\\d+),(\\d+),ioref\\)" options:0 error:NULL];
    ret = [NSMutableString stringWithString:[regex stringByReplacingMatchesInString:ret options:0 range:NSMakeRange(0, ret.length) withTemplate:@" $1 $2 R "]];
    return [NSString stringWithString:ret];
}

+ (instancetype)pdfObjectWithRepresentation:(NSData *)rep flags:(PDFRepOptions)flags {
    return [[PDFDictionary alloc] initWithNSDictionary:nil representation:[PDFUtility trimmedStringFromPDFData:rep] cgPDFDictionary:NULL parent:nil];
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [self.nsd countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    NSDictionary *copiedDictionary = [self.nsd copyWithZone:zone];
    NSString *copiedRep = [_representation copyWithZone:zone];
    return [[[self class] allocWithZone:zone] initWithNSDictionary:copiedDictionary representation:copiedRep cgPDFDictionary:_dict parent:_parent];
}

#pragma mark - Keyed Subscripting

- (id)objectForKeyedSubscript:(id<NSCopying>)key {
    return [self objectForKey:(PDFName *)key];
}


@end
