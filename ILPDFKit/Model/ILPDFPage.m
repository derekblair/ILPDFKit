// ILPDFPage.m
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

#import "ILPDFPage.h"
#import "ILPDFDictionary.h"

@interface ILPDFPage(Private)
- (CGRect)rotateBox:(CGRect)box;
@end

@implementation ILPDFPage {
    CGPDFPageRef _page;
    ILPDFDictionary *_dictionary;
    ILPDFDictionary *_resources;
}

#pragma mark - NSObject


- (id)init {
    void *page = NULL;
    self = [self initWithPage:page];
    return self;
}


#pragma mark - Initialization

- (instancetype)initWithPage:(CGPDFPageRef)pg {
    NSParameterAssert(pg);
    self = [super init];
    if (self != nil) {
        _page = pg;
    }
    return self;
}

#pragma mark - Getter

- (ILPDFDictionary *)dictionary {
    if (_dictionary == nil) {
        _dictionary = [[ILPDFDictionary alloc] initWithDictionary:CGPDFPageGetDictionary(_page)];
    }
    return _dictionary;
}

- (ILPDFDictionary *)resources {
    if (_resources == nil) {
        _resources = [self.dictionary inheritableValueForKey:@"Resources"];
    }
    return _resources;
}

- (UIImage *)thumbNailImage {
    NSData *dat = [self.dictionary[@"Thumb"] data];
    if (dat) {
        return [UIImage imageWithData:dat];
    }
    return nil;
}

- (NSUInteger)pageNumber {
    return CGPDFPageGetPageNumber(_page);
}

- (NSInteger)rotationAngle {
    return CGPDFPageGetRotationAngle(_page);
}

- (CGRect)mediaBox {
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFMediaBox)];
}

- (CGRect)cropBox {
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFCropBox)];
}

- (CGRect)bleedBox {
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFBleedBox)];
}

- (CGRect)trimBox {
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFTrimBox)];
}

- (CGRect)artBox {
    return [self rotateBox:CGPDFPageGetBoxRect(_page, kCGPDFArtBox)];
}

#pragma mark - Private

- (CGRect)rotateBox:(CGRect)box {
    CGRect ret= box;
    switch ([self rotationAngle]%360) {
        case 0:
            break;
        case 90:
            ret = CGRectMake(ret.origin.x,ret.origin.y,ret.size.height,ret.size.width);
            break;
        case 180:
            break;
        case 270:
            ret = CGRectMake(ret.origin.x,ret.origin.y,ret.size.height,ret.size.width);
        default:
            break;
    }
    return ret;
}

@end
