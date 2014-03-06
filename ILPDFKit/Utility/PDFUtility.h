//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>


/** The PDFUtility class represents a singleton that implements a range of PDF utility functions.
 */

@interface PDFUtility : NSObject

/**---------------------------------------------------------------------------------------
 * @name Creating a PDF context
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a PDF context.
 @param inMediaBox The media box defining the pages for the PDF context.
 @param path Points to the file to attach to the context.
 @return A new PDF context, or NULL if a context could not be created. You are responsible for releasing this object using CGContextRelease.
 */
+(CGContextRef)outputPDFContextCreate:(const CGRect *)inMediaBox Path:(CFStringRef)path;

/**---------------------------------------------------------------------------------------
 * @name Creating a PDF Document
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a PDF Document.
 @param data The NSData object from which to define to the PDF.
 @return A new Quartz PDF document, or NULL if a document could not be created. You are responsible for releasing the object using CGPDFDocumentRelease.
 */

+(CGPDFDocumentRef)createPDFDocumentRefFromData:(NSData*)data;

/** Creates a PDF Document.
 @param name The resource defining the PDF file to create the document from.
 @return A new Quartz PDF document, or NULL if a document could not be created. You are responsible for releasing the object using CGPDFDocumentRelease.
 */
+(CGPDFDocumentRef)createPDFDocumentRefFromResource:(NSString*)name;

/** Creates a PDF Document.
 @param pathToPdfDoc The file path defining the PDF file to create the document from.
 @return A new Quartz PDF document, or NULL if a document could not be created. You are responsible for releasing the object using CGPDFDocumentRelease.
 */
+(CGPDFDocumentRef)createPDFDocumentRefFromPath:(NSString*)pathToPdfDoc;


/** Creates a PDF compatible string escaped to remove PDF delimeter characters .
 @param stringToEncode The string to encode.
 @return An ecoded string. 
 */
+(NSString*)pdfEncodedString:(NSString*)stringToEncode;

/** Finds the proper string reprentation of a PDF name string or number
 @param obj The instance wrapping the PDF object.
 @return The string representation
 */
+(NSString*)pdfObjectRepresentationFrom:(id)obj;

/**
 @return The whitespace character set as defined by the PDF standard.
 */
+(NSCharacterSet*)whiteSpaceCharacterSet;


/**
 @param str The string to convert.
 @return The string resulting from replacing all white space sequences (including comments) in str with single space (32) characters.
 */
+(NSString*)stringReplacingWhiteSpaceWithSingleSpace:(NSString*)str;


/**
 @param str The string to encode.
 @return The URL encoded string of str.
 */
+(NSString*)urlEncodeString:(NSString*)str;


/**
 @param str The string to decode.
 @return The decoded string of str.
 */
+(NSString*)decodeURLEncodedString:(NSString*)str;


/**
 @param str The string to encode.
 @return The URL encoded string of str.
 */
+(NSString*)urlEncodeStringXML:(NSString*)str;


@end
