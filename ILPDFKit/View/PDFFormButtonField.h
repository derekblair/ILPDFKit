//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <UIKit/UIKit.h>
#import "PDFWidgetAnnotationView.h"


/** The PDFFormButtonField represents a view for a PDF button field.
 */
@interface PDFFormButtonField :PDFWidgetAnnotationView


/** YES if a radio button, NO otherwise.
 */
@property(nonatomic) BOOL radio;

/** YES if button or another button in its field must be on, NO otherwise.
 */
@property(nonatomic) BOOL noOff;

/** YES if button is a pushbutton.
 */
@property(nonatomic) BOOL pushButton;

/** The name of the button if a push button.
 */
@property(nonatomic,strong) NSString* name;


/** The export value for the button's on state.
 @discussion
 For a simple two button field to choose 'Female' of 'Male' for example, 
 the export values would be 'Female', 'Male'.
 */
@property(nonatomic,strong) NSString* exportValue;


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFFormButtonField
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFFormButtonField
 
 @param frame The new view's frame.
 @param rad YES if a radio button, otherwise NO.
 @return A new PDFFormButtonField object.
 */
-(id)initWithFrame:(CGRect)frame Radio:(BOOL)rad;

/**---------------------------------------------------------------------------------------
 * @name Post Initialization
 *  ---------------------------------------------------------------------------------------
 */

/** Sets up the button to receive touch events. 
 @discussion Must be called after the button is added to a superview.
 */
-(void)setButtonSuperview;



@end
