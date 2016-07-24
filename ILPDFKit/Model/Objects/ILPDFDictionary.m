// ILPDFDictionary.m
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
#import "ILPDFString.h"
#import "ILPDFNumber.h"
#import "ILPDFNull.h"


@interface ILPDFDictionary(PrivateGetters)
- (NSDictionary *)nsd;
@end

@interface ILPDFDictionary(PrivateInitializers)
- (instancetype)initWithNSDictionary:(NSDictionary *)dict representation:(NSString *)rep cgPDFDictionary:(CGPDFDictionaryRef)cgdict parent:(ILPDFDictionary *)parent;
@end

@interface ILPDFDictionary(PrivateIndexedObjectQueries)
- (id<ILPDFObject>)pdfObjectFromKey:(ILPDFName *)key;
- (ILPDFDictionary *)dictionaryFromKey:(ILPDFName *)key;
- (ILPDFArray *)arrayFromKey:(ILPDFName *)key;
- (ILPDFString *)stringFromKey:(ILPDFName *)key;
- (ILPDFName *)nameFromKey:(ILPDFName *)key;
- (ILPDFNumber *)integerFromKey:(ILPDFName *)key;
- (ILPDFNumber *)realFromKey:(ILPDFName *)key;
- (ILPDFNumber *)booleanFromKey:(ILPDFName *)key;
- (ILPDFStream *)streamFromKey:(ILPDFName *)key;
- (ILPDFNull *)nullFromKey:(ILPDFName *)key;
- (CGPDFObjectType)typeForKey:(ILPDFName *)key;
@end

@implementation ILPDFDictionary {
    NSDictionary *_nsd;
    NSString *_representation;
    CGPDFDictionaryRef _dict;
}

void checkKeys(const char *key,CGPDFObjectRef value,void *info) {
    ILPDFName *nameToAdd = [[ILPDFName alloc] initWithPDFCString:key];
    [(__bridge NSMutableArray *)info addObject:nameToAdd];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (object == self) return  YES;
    if (![object isKindOfClass:[ILPDFDictionary class]]) return NO;
    return [self isEqualToDictionary:object];
}

- (NSUInteger)hash {
    return [self.nsd hash];
}

- (id)init {
    void  *dict = NULL;
    self = [self initWithDictionary:dict];
    return self;
}

#pragma mark - ILPDFDictionary

- (instancetype)initWithDictionary:(CGPDFDictionaryRef)pdict {
    NSParameterAssert(pdict);
    self = [super init];
    if (self != nil) {
        _dict = pdict;
    }
    return self;
}

- (ILPDFDictionary *)dictionaryByMergingDictionary:(NSDictionary *)changes {
    NSMutableDictionary *temp = [self.nsd mutableCopy];
    for (ILPDFName *key in changes) {
        temp[key] = changes[key];
    }
    return [[ILPDFDictionary alloc] initWithNSDictionary:[NSDictionary dictionaryWithDictionary:temp] representation:nil cgPDFDictionary:NULL parent:nil];
}

- (id<ILPDFObject>)objectForKey:(ILPDFName *)aKey {
    return self.nsd[aKey];
}

- (NSArray *)allKeys {
    return [self.nsd allKeys];
}

- (NSArray *)allValues {
    return [self.nsd allValues];
}

- (id<ILPDFObject>)inheritableValueForKey:(ILPDFName *)key {
    ILPDFDictionary *iter = nil;
    NSMutableArray *chain = [NSMutableArray array];
    for (iter = self; iter && iter[key] == nil; iter = iter.parent) {
        // If we have a cycle, break.
        if ([chain containsObject:iter]) break;
        [chain addObject:iter];
    }
    return iter[key];
}

- (NSArray *)parentValuesForKey:(ILPDFName *)key {
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *chain = [NSMutableArray array];
    for (ILPDFDictionary *iter = self; iter; iter = iter.parent) {
        // If we have a cycle, break.
        if ([chain containsObject:iter]) break;
        [chain addObject:iter];
        if (iter[key]) [result addObject:iter[key]];
    }
    return [NSArray arrayWithArray:result];;
}

- (BOOL)isEqualToDictionary:(ILPDFDictionary *)otherDictionary {
    return [self.nsd isEqualToDictionary:otherDictionary.nsd];
}

- (NSUInteger)count {
    return [self.nsd count];
}

- (ILPDFDictionary *)parent {
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
            ILPDFObjectParser *parser = [ILPDFObjectParser parserWithBytes:[ILPDFUtility dataFromPDFString:_representation]];
            for (id pdfObject in parser) {
                [keysAndValues addObject:pdfObject];
            }
            if ([keysAndValues count]&1)return nil;
            for (NSUInteger c = 0; c < [keysAndValues count]/2; c++) {
                ILPDFName *key = keysAndValues[2*c];
                [keys addObject:key];
                nsdFiller[key] = keysAndValues[2*c+1];
            }
        }

        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        for (ILPDFName *key in keys) {
           id set = (_dict != NULL ? [self pdfObjectFromKey:key]:nsdFiller[key]);
           if (set != nil) {
              if ([set isKindOfClass:[ILPDFDictionary class]]) {
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

- (instancetype)initWithNSDictionary:(NSDictionary *)dict representation:(NSString *)rep cgPDFDictionary:(CGPDFDictionaryRef)cgdict parent:(ILPDFDictionary *)parent {
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

- (id<ILPDFObject>)pdfObjectFromKey:(ILPDFName *)key {
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

- (ILPDFDictionary *)dictionaryFromKey:(ILPDFName *)key {
    CGPDFDictionaryRef dr = NULL;
    if (CGPDFDictionaryGetDictionary(_dict,[key pdfCString], &dr)) {
        return [[ILPDFDictionary alloc] initWithDictionary:dr];
    }
    return nil;
}

- (ILPDFArray *)arrayFromKey:(ILPDFName *)key {
    CGPDFArrayRef ar = NULL;
    if (CGPDFDictionaryGetArray(_dict,[key pdfCString], &ar)) {
        return [[ILPDFArray alloc] initWithArray:ar];
    }
    return nil;
}

- (ILPDFString *)stringFromKey:(ILPDFName *)key {
    CGPDFStringRef str = NULL;
    if (CGPDFDictionaryGetString(_dict,[key pdfCString], &str)) {
        return [[ILPDFString alloc] initWithTextString:(__bridge NSString *)CGPDFStringCopyTextString(str)];
    }
    return nil;
}

- (ILPDFName *)nameFromKey:(ILPDFName *)key {
    const char* targ = NULL;
    if (CGPDFDictionaryGetName(_dict,[key pdfCString], &targ))  {
        return [[ILPDFName alloc] initWithPDFCString:targ];
    }
    return nil;
}

- (ILPDFNumber *)integerFromKey:(ILPDFName *)key {
    CGPDFInteger targ;
    if (CGPDFDictionaryGetInteger(_dict,[key pdfCString], &targ)) {
        return @((long)targ);
    }
    return nil;
}

- (ILPDFNumber *)realFromKey:(ILPDFName *)key {
    CGPDFReal targ;
    if (CGPDFDictionaryGetNumber(_dict,[key pdfCString], &targ)) {
        return @((double)targ);
    }
    return nil;
}


- (ILPDFNumber *)booleanFromKey:(ILPDFName *)key {
    CGPDFBoolean targ;
    if (CGPDFDictionaryGetBoolean(_dict,[key pdfCString], &targ)) {
        return @((BOOL)targ);
    }
    return nil;
}

- (ILPDFStream *)streamFromKey:(ILPDFName *)key {
    CGPDFStreamRef targ = NULL;
    if (CGPDFDictionaryGetStream(_dict,[key pdfCString], &targ)) {
        return [[ILPDFStream alloc] initWithStream:targ];
    }
    return nil;
}

- (ILPDFNull *)nullFromKey:(ILPDFName *)key {
    return [ILPDFNull null];
}

- (CGPDFObjectType)typeForKey:(ILPDFName *)key {
    if (_dict != NULL) {
        CGPDFObjectRef obj = NULL;
        if (CGPDFDictionaryGetObject(_dict,[key pdfCString], &obj)) {
            return CGPDFObjectGetType(obj);
        }
        return kCGPDFObjectTypeName;
    }
    return kCGPDFObjectTypeNull;
}


#pragma mark - ILPDFObject

- (CGPDFObjectType)type {
    return kCGPDFObjectTypeDictionary;
}

- (NSString *)pdfFileRepresentation {
    NSArray *keys = [self allKeys];
    NSMutableString *ret = [NSMutableString stringWithString:@"<<\n"];
    for (NSUInteger i = 0; i < [keys count]; i++) {
        ILPDFName *key = keys[i];
        id<ILPDFObject> obj = self[key];
        [ret appendString:[NSString stringWithFormat:@"%@ %@\n",[key pdfFileRepresentation],[obj pdfFileRepresentation]]];
    }
    [ret appendString:@">>"];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\((\\d+),(\\d+),ioref\\)" options:0 error:NULL];
    ret = [NSMutableString stringWithString:[regex stringByReplacingMatchesInString:ret options:0 range:NSMakeRange(0, ret.length) withTemplate:@" $1 $2 R "]];
    return [NSString stringWithString:ret];
}

+ (instancetype)pdfObjectWithRepresentation:(NSData *)rep flags:(ILPDFRepOptions)flags {
    return [[ILPDFDictionary alloc] initWithNSDictionary:nil representation:[ILPDFUtility trimmedStringFromPDFData:rep] cgPDFDictionary:NULL parent:nil];
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
    return [self objectForKey:(ILPDFName *)key];
}


@end
