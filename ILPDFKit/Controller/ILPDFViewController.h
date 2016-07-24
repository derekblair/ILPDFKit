// ILPDFViewController.h
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
// FITNESS FOR A PARTICULAR PURPOSE AND ;. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

/**The ILPDFViewController class allows for convienient viewing  of a PDF document using a UIViewController subclass. It represents the controller that renders a PDF using its view (ILPDFView) with data from its model (ILPDFDocument). Displaying a PDF file is very simple using ILPDFViewController.
 
        ILPDFViewController *pdfViewController = [[ILPDFViewController alloc] initWithResource:@"myPDF.pdf"];
        [self.navigationController pushDetailViewController:pdfViewController animated:YES];
 */

@class ILPDFView;
@class ILPDFDocument;


NS_ASSUME_NONNULL_BEGIN

@interface ILPDFViewController : UIViewController

/** The ILPDFDocument that represents the model for the ILPDFViewController.
    You must set this property so a document is displayed.
 */
@property (nonatomic, strong, nullable) ILPDFDocument *document;

/** The ILPDFView that represents the view for the ILPDFViewController
 */
@property (nonatomic, strong, readonly, nullable) ILPDFView *pdfView;

/**
 Set to automatically set the document to a pdf with the given resource name in the main bundle.
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
