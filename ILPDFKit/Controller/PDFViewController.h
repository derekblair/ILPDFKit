//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


/**The PDFViewController class allows for convienient viewing  of a PDF document using a UIViewController subclass. It represents the controller that renders a PDF using its view PDFView with data from its model PDFDocument. Displaying a PDF file is very simple using PDFViewController.
 
        PDFViewController* pdfViewController = [[PDFViewController alloc] initWithResource:@"myPDF.pdf"];
        [self.navigationController pushDetailViewController:pdfViewController animated:YES];
        [pdfViewController release];
 */


@class PDFView;
@class PDFDocument;

@interface PDFViewController : UIViewController

/** The PDFDocument that represents the model for the PDFViewController
 */
@property(nonatomic,strong) PDFDocument* document;

/** The PDFView that represents the view for the PDFViewController
 */
@property(nonatomic,strong) PDFView* pdfView;



/**---------------------------------------------------------------------------------------
 * @name Creating a PDFViewController
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFViewController.
 
 @param data Content of the document.
 @return A new instance of PDFViewController initialized with data.
 */

-(id)initWithData:(NSData*)data;

/** Creates a new instance of PDFViewController.
 
 @param name Resource to load.
 @return A new instance of PDFViewController initialized with a PDF resource named name.
 */
-(id)initWithResource:(NSString*)name;

/** Creates a new instance of PDFViewController.
 
 @param path Points to PDF file to load.
 @return A new instance of PDFViewController initialized with a PDF located at path.
 */
-(id)initWithPath:(NSString*)path;


/**---------------------------------------------------------------------------------------
 * @name Reloading Content
 *  ---------------------------------------------------------------------------------------
 */

/** Reloads the entire PDF.
 */
-(void)reload;

/**---------------------------------------------------------------------------------------
 * @name Appearance
 *  ---------------------------------------------------------------------------------------
 */

/** Sets the background color for the PDF view.
 @param color The new color.
 */
-(void)setBackColor:(UIColor*)color;







@end
