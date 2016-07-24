// ILPDFPage.h
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
#import <UIKit/UIKit.h>


/** The ILPDFPage class encapsulates a single page contained in a ILPDFDocument.
 Essentially, is is a wrapper class for a CGPDFPageRef.
 
    CGPDFPageRef pdfPRef = myCGPDFPageRef;
    ILPDFPage* pdfPage = [[ILPDFPage alloc] initWithPage:pdfPRef];
 
 ILPDFPage consists of the data representing the page info.
 */

@class ILPDFDictionary;

NS_ASSUME_NONNULL_BEGIN

@interface ILPDFPage : NSObject




/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFPage
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of ILPDFPage wrapping a CGPDFPageRef
 
 @param pg A CGPDFPageRef representing the PDF page.
 @return A new ILPDFPage object. 
 */
- (instancetype)initWithPage:(CGPDFPageRef)pg NS_DESIGNATED_INITIALIZER;

/** Returns the thumbnail image.
 @return The thumbnail image as a UIImage or nil if no such image exists.
 */
- (nullable UIImage *)thumbNailImage;

/** The page dictionary.
 */
@property (nonatomic, readonly, null_resettable) ILPDFDictionary *dictionary;

/** The page number beginning with 1.
 */
@property (nonatomic, readonly) NSUInteger pageNumber;

/** The angle at which the page should be rotated.
 */
@property (nonatomic, readonly) NSInteger rotationAngle;

/** The media box retangle for the page.
 */
@property (nonatomic, readonly) CGRect mediaBox;

/** The crop box retangle for the page.
 */
@property (nonatomic, readonly) CGRect cropBox;

/** The bleed box retangle for the page.
 */
@property (nonatomic, readonly) CGRect bleedBox;

/** The trim box retangle for the page.
 */
@property (nonatomic, readonly) CGRect trimBox;

/** The art box retangle for the page.
 */
@property (nonatomic, readonly) CGRect artBox;

/** The CGPDFPageRef that defines the page.
 */
@property (nonatomic, readonly) CGPDFPageRef page;

/** The resource dictionary for the page.
 */
@property (nonatomic, readonly, null_resettable) ILPDFDictionary *resources;

@end


NS_ASSUME_NONNULL_END
