//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>
#import "PDFObject.h"


/** The PDFStream class encapsulates a PDF stream object contained in a PDFDocument.
 Essentially, is is a wrapper class for a CGPDFStreamRef.
 
    CGPDFStreamRef pdfSRef = myCGPDFStreamRef;
    PDFStream* pdfStream = [[PDFStream alloc] initWithStream:pdfSRef];
 
 PDFStream consists of the data representing the stream content and a NSDictionary representing the content info.
 */


@class PDFDictionary;

@interface PDFStream : PDFObject

/** The data representing the stream content.
 @discussion It's important to reference dataFormat so that the data can be correctly interpreted.
 */
@property(nonatomic,readonly) NSData* data;


/** The data format for the stream content.
 */
@property(nonatomic,readonly) CGPDFDataFormat dataFormat;

/** The stream dictionary.
 */
@property(nonatomic,readonly) PDFDictionary* dictionary;


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFStream
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFStream wrapping a CGPDFStreamRef
 
 @param pstrm A CGPDFStreamRef representing the PDF stream.
 @return A new PDFStream object.
 */
-(id)initWithStream:(CGPDFStreamRef)pstrm;



@end


