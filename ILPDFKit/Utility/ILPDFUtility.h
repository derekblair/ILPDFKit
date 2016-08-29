// ILPDFUtility.h
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
#import <QuartzCore/QuartzCore.h>


NS_ASSUME_NONNULL_BEGIN

/** The ILPDFUtility class represents a singleton that implements a range of PDF utility functions.
 */

@interface ILPDFUtility : NSObject

/**---------------------------------------------------------------------------------------
 * @name Creating a PDF context
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a PDF context.
 @param inMediaBox The media box defining the pages for the PDF context.
 @param path Points to the file to attach to the context.
 @return A new PDF context, or NULL if a context could not be created. You are responsible for releasing this object using CGContextRelease.
 */
+ (CGContextRef)outputPDFContextCreate:(const CGRect *)inMediaBox path:(CFStringRef)path CF_RETURNS_NOT_RETAINED;

/**---------------------------------------------------------------------------------------
 * @name Creating a PDF Document
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a PDF Document.
 @param data The NSData object from which to define to the PDF.
 @return A new Quartz PDF document, or NULL if a document could not be created. You are responsible for releasing the object using CGPDFDocumentRelease.
 */

+ (CGPDFDocumentRef)createPDFDocumentRefFromData:(NSData *)data CF_RETURNS_NOT_RETAINED;

/** Creates a PDF Document.
 @param name The resource defining the PDF file to create the document from.
 @return A new Quartz PDF document, or NULL if a document could not be created. You are responsible for releasing the object using CGPDFDocumentRelease.
 */
+ (CGPDFDocumentRef)createPDFDocumentRefFromResource:(NSString *)name CF_RETURNS_NOT_RETAINED;

/** Creates a PDF Document.
 @param pathToPdfDoc The file path defining the PDF file to create the document from.
 @return A new Quartz PDF document, or NULL if a document could not be created. You are responsible for releasing the object using CGPDFDocumentRelease.
 */
+ (CGPDFDocumentRef)createPDFDocumentRefFromPath:(NSString *)pathToPdfDoc CF_RETURNS_NOT_RETAINED;


/**---------------------------------------------------------------------------------------
 * @name Character Sets and Encodings
 *  ---------------------------------------------------------------------------------------
 */


/**
 @return The whitespace character set as defined by the PDF standard.
 */
+ (NSCharacterSet *)whiteSpaceCharacterSet;

/**
 @return The delimeter character set as defined by the PDF standard.
 */
+ (NSCharacterSet *)delimeterCharacterSet;

/**
 @param str The string to encode.
 @return The XML safe encoded string of str. Essentially escapes angle brackets.
 */
+ (NSString *)encodeStringForXML:(NSString *)str;

/**
 @param str The string to remove PDF whitespace characters from.
 @return The result after removing PDF whitespace characters from str.
 */
+ (NSString *)stringByRemovingWhiteSpaceFrom:(NSString *)str;

/**
 @return An array containing the ASCII character codes for all PDF delimiter characters.
 */
+ (NSArray *)delimiterCharacterCodes;

/**
 @return An array containing the ASCII character codes for all PDF white space characters.
 */
+ (NSArray *)whiteSpaceCharacterCodes;

/**
 @param data A byte sequence.
 @return A PDF compliant , ASCII string representation of the byte sequence with whitespace trimmed.
 */
+ (NSString *)trimmedStringFromPDFData:(NSData *)data;

/**
 @param data A byte sequence.
 @return A PDF compliant , ASCII string representation of the byte sequence.
 */
+ (NSString *)stringFromPDFData:(NSData *)data;

/**
 @param  str An ASCII string.
 @return A PDF compliant byte sequence representing the string.
 */
+ (NSData *)dataFromPDFString:(NSString *)str;

/**
 @param str A C string.
 @return A PDF compliant , ASCII string representation of the C string.
 */
+ (NSString *)stringFromPDFCString:(const char *)str;

/**
 @param  str A ASCII string.
 @return A PDF compliant C string representing the string.
 */
+ (const char *)cStringFromPDFString:(NSString *)str;


@end


NS_ASSUME_NONNULL_END
