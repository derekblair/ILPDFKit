// PDFObject.h
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

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, PDFRepOptions) {
    PDFRepOptionNone = 0,
    PDFRepOptionUseUTF8 = 1 << 0
};

/** All basic PDF object classes implement this protocol. PDFArray, PDFDictionary, PDFString, PDFName etc.
 */
@protocol PDFObject <NSObject, NSCopying>

/**
 @param rep A byte sequence respresention of the object as it appears in a PDF file.
 @param flags Optional flags to specifiy how to interpret the byte sequence.
 @return A PDF object based on the representation, or nil if the representation is invalid.
 */
+ (instancetype)pdfObjectWithRepresentation:(NSData *)rep flags:(PDFRepOptions)flags;

/**
 @return An ASCII string representation of the object.
 */
- (NSString *)pdfFileRepresentation;

/**
 @return The type of the PDF as described by the Core Graphics framework.
 */
- (CGPDFObjectType)type;

@end













