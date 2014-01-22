

#import <UIKit/UIKit.h>
/** The PDFView class allows for viewing a PDF file. The controller PDFViewController uses PDFView as its view and PDFDocument as its model.
 PDFView is typically not directly instantiated, but instead is used as the instance that comes with PDFViewController.
 */


@class PDFWidgetAnnotationView;

@interface PDFView : UIView<UIScrollViewDelegate,UIGestureRecognizerDelegate>

/** The array contains the PDFWidgetAnnotationView instances that are subviews of the pdfView's scrollView.
 */
@property(nonatomic,readonly) NSMutableArray* pdfWidgetAnnotationViews;


/** The view in pdfWidgetAnnotationViews has holds the input focus.
 */
@property(nonatomic,assign) PDFWidgetAnnotationView* activeWidgetAnnotationView;


/** The webview used to render the PDF.
 */
@property(nonatomic,readonly) UIWebView* pdfView;


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFView
 *  ---------------------------------------------------------------------------------------
 */
/** Creates a new instance of PDFView.
 
 @param frame Frame of the view.
 @param dataOrPath Either NSData for PDF data or NSString for a PDF file path.
 @param widgetAnnotationViews NSArray of instances of PDFWidgetAnnotationalElementView to be added to the pdfView scrollView.
 @return A new instance of PDFView.
 */

-(id)initWithFrame:(CGRect)frame DataOrPath:(id)dataOrPath AdditionViews:(NSArray*)widgetAnnotationViews;


/**---------------------------------------------------------------------------------------
 * @name Adding and Removing Additions
 *  ---------------------------------------------------------------------------------------
 */
/** Adds an addition view.
 
 
 @param viewToAdd PDFWidgetAnnotationalElementView to be added to the pdfView scrollView.
 
 */

-(void)addPDFWidgetAnnotationView:(PDFWidgetAnnotationView*)viewToAdd;


/** Removes an addition view.
 
 
 @param viewToRemove PDFWidgetAnnotationalElementView to be removed from the pdfView scrollView.

 */
-(void)removePDFWidgetAnnotationView:(PDFWidgetAnnotationView*)viewToRemove;


/** Sets the UI addition views
 @param additionViews The views to add.
 
 */

-(void)setWidgetAnnotationViews:(NSArray*)additionViews;




@end
