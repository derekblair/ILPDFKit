

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


/**The PDFViewController class allows for convienient viewing  of a PDF document using a UIViewController subclass. It represents the controller that renders a PDF using its view PDFView with data from its model PDFDocument. Displaying a PDF file is very simple using PDFViewController.
 
        PDFViewController* pdfViewController = [[PDFViewController alloc] initWithResource:@"myPDF.pdf"];
        [self.navigationController pushDetailViewController:pdfViewController animated:YES];
        [pdfViewController release];
 */




@class PDFView;
@class PDFDocument;

@interface PDFViewController : UIViewController<UIPrintInteractionControllerDelegate>

/** The PDFDocument that represents the model for the PDFViewController
 */
@property(nonatomic,retain) PDFDocument* document;

/** The PDFView that represents the view for the PDFViewController
 */
@property(nonatomic,retain) PDFView* pdfView;



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
 * @name Creating Flattened Documents
 *  ---------------------------------------------------------------------------------------
 */


/** Creates a new PDF document flattened with any overlayed AcroForms
 @return A new instance of PDFDocument composed of the orginal PDF with all form fields rendered as static text and images. Thus the returned PDF has no forms and is suitable for printing. The caller is responsible for releasing the returned instance.
 */
-(PDFDocument*)createFlattenedDocument;


/**
 Converts a PDF page to an image.
 @param page The page number. 1 is the forst page.
 @param width The desired width of the returned image.
 @return A UIImage representing the page.
 */

-(UIImage*)imageFromPage:(NSUInteger)page width:(float)width;

/**---------------------------------------------------------------------------------------
 * @name Printing
 *  ---------------------------------------------------------------------------------------
 */

/** Opens a print interface
 @param bbi The UIBarButtonItem that triggers display of the print interface.
 
 */
-(BOOL)openPrintInterfaceFromBarButtonItem:(UIBarButtonItem*)bbi;



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
