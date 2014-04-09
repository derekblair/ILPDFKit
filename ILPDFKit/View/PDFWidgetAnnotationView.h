//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>

@class PDFWidgetAnnotationView;
@class PDFView;

/** The PDFWidgetAnnotationViewDelegate responds to user interaction with a PDFWidgetAnnotationView.
 */
@protocol PDFWidgetAnnotationViewDelegate <NSObject>
/** Called when the value changes.
 @param sender The sending PDFWidgetAnnotationView.
 */
    -(void)widgetAnnotationValueChanged:(PDFWidgetAnnotationView*)sender;
/** Called when the the element is focused or expanded.
 @param sender The sending PDFWidgetAnnotationView.
 */
    -(void)widgetAnnotationEntered:(PDFWidgetAnnotationView*)sender;
/** Called when the options changes for choice field views.
 @param sender The sending PDFWidgetAnnotationView.
 */
    -(void)widgetAnnotationOptionsChanged:(PDFWidgetAnnotationView*)sender;
@end

/** The PDFWidgetAnnotationView represents a subview of a PDFView that represents an interactive or accessory element. A PDFForm is an example.
 */
@interface PDFWidgetAnnotationView : UIView
{
    CGFloat _zoomScale;
}


/** The value of the element.
 @discussion If there is an associated PDFForm to the view, then set of values are synced using key value observing.
 */
@property(nonatomic,strong) NSString* value;

/** The options of the element.
 @discussion If there is an associated PDFForm to the view, then set of options are synced using key value observing.
 */
@property(nonatomic,strong) NSArray* options;


/** The initial frame of the view, without any transformations applied to its superview.
 */
@property(nonatomic,readonly) CGRect baseFrame;


/** The delegate.
 */
@property(nonatomic,weak) NSObject<PDFWidgetAnnotationViewDelegate>* delegate;


/** The parent view.
 */
@property(nonatomic,weak) PDFView* parentView;



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
 * @name Managing Focus
 *  ---------------------------------------------------------------------------------------
 */

/** Resigns th input focus.
 */
-(void)resign;

@end
