// PDFViewController.h
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
// FITNESS FOR A PARTICULAR PURPOSE AND ;. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

/**The PDFViewController class allows for convienient viewing  of a PDF document using a UIViewController subclass. It represents the controller that renders a PDF using its view (PDFView) with data from its model (PDFDocument). Displaying a PDF file is very simple using PDFViewController.
 
        PDFViewController *pdfViewController = [[PDFViewController alloc] initWithResource:@"myPDF.pdf"];
        [self.navigationController pushDetailViewController:pdfViewController animated:YES];
 */

@class PDFView;
@class PDFDocument;


NS_ASSUME_NONNULL_BEGIN

@interface PDFViewController : UIViewController

/** The PDFDocument that represents the model for the PDFViewController
 */
@property (nonatomic, strong, nullable) PDFDocument *document;

/** The PDFView that represents the view for the PDFViewController
 */
@property (nonatomic, strong, readonly, nullable) PDFView *pdfView;

/**
 Set to automatically set the document to a pdf with the given name in the main bundle.
 */
@property (nonatomic, strong, nullable) IBInspectable NSString *pdfName;


/**---------------------------------------------------------------------------------------
 * @name Reloading Content
 *  ---------------------------------------------------------------------------------------
 */

/** Reloads the entire PDF.
 */
- (void)reload;

@end

NS_ASSUME_NONNULL_END
