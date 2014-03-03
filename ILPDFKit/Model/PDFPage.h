//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>


/** The PDFPage class encapsulates a single page contained in a PDFDocument.
 Essentially, is is a wrapper class for a CGPDFPageRef.
 
    CGPDFPageRef pdfPRef = myCGPDFPageRef;
    PDFPage* pdfPage = [[PDFPage alloc] initWithPage:pdfPRef];
 
 PDFPage consists of the data representing the page info.
 */

@class PDFDictionary;

@interface PDFPage : NSObject

/**---------------------------------------------------------------------------------------
 * @name Creating a PDFPage
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFPage wrapping a CGPDFPageRef
 
 @param pg A CGPDFPageRef representing the PDF page.
 @return A new PDFPage object. 
 */
-(id)initWithPage:(CGPDFPageRef)pg;


/** Returns the thumbnail image.
 
 @return The thumbnail image as a UIImage or nil if no such image exists.
 */
-(UIImage*)thumbNailImage;

/** The page dictionary.
 */
@property(nonatomic,readonly) PDFDictionary* dictionary;



/** The page number beginning with 1.
 
 */
@property(nonatomic,readonly) NSUInteger pageNumber;



/** The angle at which the page should be rotated.
 
 */
@property(nonatomic,readonly) NSInteger rotationAngle;

/** The media box retangle for the page.
 
 */
@property(nonatomic,readonly) CGRect mediaBox;

/** The crop box retangle for the page.
 
 */
@property(nonatomic,readonly) CGRect cropBox;

/** The bleed box retangle for the page.
 
 */
@property(nonatomic,readonly) CGRect bleedBox;

/** The trim box retangle for the page.
 
 */
@property(nonatomic,readonly) CGRect trimBox;

/** The art box retangle for the page.
 
 */
@property(nonatomic,readonly) CGRect artBox;

/** The CGPDFPageRef that defines the page.
 
 */
@property(nonatomic,readonly) CGPDFPageRef page;

/** The resource dictionary for the page.
 
 */
@property(nonatomic,readonly) PDFDictionary* resources;

@end
