
#import <Foundation/Foundation.h>

@class PDFUIAdditionElementView;


/** The PDFUIAdditionElementViewDelegate responds to user interaction with a PDFUIAdditionElementView.
 */
@protocol PDFUIAdditionElementViewDelegate <NSObject>
/** Called when the value changes.
 @param sender The sending PDFUIAdditionElementView.
 */
    -(void)uiAdditionValueChanged:(PDFUIAdditionElementView*)sender;
/** Called when the the element is focused or expanded.
 @param sender The sending PDFUIAdditionElementView.
 */
    -(void)uiAdditionEntered:(PDFUIAdditionElementView*)sender;
/** Called when the options changes for choice field views.
 @param sender The sending PDFUIAdditionElementView.
 */
    -(void)uiAdditionOptionsChanged:(PDFUIAdditionElementView*)sender;
@end

/** The PDFUIAdditionElementView represents a subview of a PDFView that represents an interactive or accessory element. A PDFForm is an example.
 */
@interface PDFUIAdditionElementView : UIView
{
    CGFloat _zoomScale;
    NSObject<PDFUIAdditionElementViewDelegate>* _delegate;
}


/** The value of the element.
 @discussion If there is an associated PDFForm to the view, then set of values are synced using key value observing.
 */
@property(nonatomic,retain) NSString* value;

/** The options of the element.
 @discussion If there is an associated PDFForm to the view, then set of options are synced using key value observing.
 */
@property(nonatomic,retain) NSArray* options;


/** The initial frame of the view, without any transformations applied to its superview.
 */
@property(nonatomic,readonly) CGRect baseFrame;


/** The delegate.
 */
@property(nonatomic,assign) NSObject<PDFUIAdditionElementViewDelegate>* delegate;



/**---------------------------------------------------------------------------------------
 * @name Updating Metrics
 *  ---------------------------------------------------------------------------------------
 */

/** Updates the view based on the zoom level of its UIScrollView superview.
 @param zoom The new zoom level.
 */
-(void)updateWithZoom:(CGFloat)zoom;


/**---------------------------------------------------------------------------------------
 * @name Updating Data
 *  ---------------------------------------------------------------------------------------
 */


/** Refreshes the contents.
 */
-(void)refresh;



/**---------------------------------------------------------------------------------------
 * @name Rendering
 *  ---------------------------------------------------------------------------------------
 */


/** Renders the view in vector graphics within a PDF context.
    @param ctx The PDF context to render into.
    @param rect The rectangle to render on.
 */
-(void)vectorRenderInPDFContext:(CGContextRef)ctx ForRect:(CGRect)rect;


/**---------------------------------------------------------------------------------------
 * @name Managing Focus
 *  ---------------------------------------------------------------------------------------
 */

/** Resigns th input focus.
 */
-(void)resign;

@end
