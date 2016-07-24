// ILPDFString.h
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

#import <Foundation/Foundation.h>
#import "ILPDFObject.h"

#define ILPDFString NSData


NS_ASSUME_NONNULL_BEGIN

/** ILPDFString is an alias for NSData. It represents regular and hexadecimal string PDF objects. A string object consists of a series of bytes — unsigned integer values in the range 0 to 255. Strings are interpreted according to the 7-bit ASCII encoding in the case of literal strings, however, any 8-bit value may appear in a string. Characters outside the 7-bit ASCII character set may be represented using ASCII characters via the \ddd escape sequence. eg \245
 */
@interface ILPDFString(ILPDFObject) <ILPDFObject>
/**
 @return The UTF-8 string resulting when the bytes of the receiver are interpreted as UTF-8 text.
 */
- (NSString *)utf8TextString;

/**
 @return The hexadecimal string representation of the receivers bytes, enclosed in <> brackets.
 */
- (NSString *)hexStringRepresentation;

/**
 @return The ASCII string representation of the receivers bytes. Note that ILPDFString objects are NSData objects and not text strings.
 */
- (NSString *)textString;

/**
 @param str An ASCII string.
 @return An initialized instance, based on the passed string.
 */
- (instancetype)initWithTextString:(NSString *)str;


@end


NS_ASSUME_NONNULL_END
