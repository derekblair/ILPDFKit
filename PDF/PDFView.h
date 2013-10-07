

#import <UIKit/UIKit.h>
/** The PDFView class allows for viewing a PDF file. The controller PDFViewController uses PDFView as its view and PDFDocument as its model.
 PDFView is typically not directly instantiated, but instead is used as the instance that comes with PDFViewController.
 */


@class PDFUIAdditionElementView;

@interface PDFView : UIView<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UIWebView* pdfView;
    NSMutableArray* pdfUIAdditionElementViews;
    PDFUIAdditionElementView* activeUIAdditionView;
}


/** The array contains the PDFUIAdditionElementView instances that are subviews of the pdfView's scrollView.
 */
@property(nonatomic,readonly) NSMutableArray* pdfUIAdditionElementViews;


/** The view in pdfUIAdditionElementViews has holds the input focus.
 */
@property(nonatomic,assign) PDFUIAdditionElementView* activeUIAdditionsView;


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
 @param uiAdditionViews NSArray of instances of PDFUIAdditionalElementView to be added to the pdfView scrollView.
 @return A new instance of PDFView.
 */

-(id)initWithFrame:(CGRect)frame DataOrPath:(id)dataOrPath AdditionViews:(NSArray*)uiAdditionViews;


/**---------------------------------------------------------------------------------------
 * @name Adding and Removing Additions
 *  ---------------------------------------------------------------------------------------
 */
/** Adds an addition view.
 
 
 @param viewToAdd PDFUIAdditionalElementView to be added to the pdfView scrollView.
 
 */

-(void)addPDFUIAdditionView:(PDFUIAdditionElementView*)viewToAdd;


/** Removes an addition view.
 
 
 @param viewToRemove PDFUIAdditionalElementView to be removed from the pdfView scrollView.

 */
-(void)removePDFUIAdditionView:(PDFUIAdditionElementView*)viewToRemove;


/** Sets the UI addition views
 @param additionViews The views to add.
 
 */

-(void)setUIAdditionViews:(NSArray*)additionViews;


-(void)beginRotation;
-(void)endRotation;




@end
