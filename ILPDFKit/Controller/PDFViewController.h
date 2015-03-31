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
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
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

@interface PDFViewController : UIViewController

/** The PDFDocument that represents the model for the PDFViewController
 */
@property (nonatomic, strong) PDFDocument *document;

/** The PDFView that represents the view for the PDFViewController
 */
@property (nonatomic, strong) PDFView *pdfView;


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFViewController
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFViewController.
 
 @param data Content of the document.
 @return A new instance of PDFViewController initialized with data.
 */

- (instancetype)initWithData:(NSData *)data NS_DESIGNATED_INITIALIZER;

/** Creates a new instance of PDFViewController.
 
 @param name Resource to load.
 @return A new instance of PDFViewController initialized with a PDF resource named name.
 */
- (instancetype)initWithResource:(NSString *)name NS_DESIGNATED_INITIALIZER;

/** Creates a new instance of PDFViewController.
 
 @param path Points to PDF file to load.
 @return A new instance of PDFViewController initialized with a PDF located at path.
 */
- (instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

/**---------------------------------------------------------------------------------------
 * @name Reloading Content
 *  ---------------------------------------------------------------------------------------
 */

/** Reloads the entire PDF.
 */
- (void)reload;

@end
