// ILPDFFormButtonField.h
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
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "ILPDFWidgetAnnotationView.h"

NS_ASSUME_NONNULL_BEGIN


/** The ILPDFFormButtonField represents a view for a PDF button field.
 */
@interface ILPDFFormButtonField : ILPDFWidgetAnnotationView

/** YES if a radio button, NO otherwise.
 */
@property (nonatomic) BOOL radio;

/** YES if button or another button in its field must be on, NO otherwise.
 */
@property (nonatomic) BOOL noOff;

/** YES if button is a pushbutton.
 */
@property (nonatomic) BOOL pushButton;

/** The name of the button if a push button.
 */
@property (nonatomic, strong) NSString *name;

/** The export value for the button's on state.
 @discussion
 For a simple two button field to choose 'Female' of 'Male' for example, 
 the export values would be 'Female', 'Male'.
 */
@property (nonatomic, strong) NSString *exportValue;


/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFFormButtonField
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of ILPDFFormButtonField
 
 @param frame The new view's frame.
 @param rad YES if a radio button, otherwise NO.
 @return A new ILPDFFormButtonField object.
 */
- (instancetype)initWithFrame:(CGRect)frame radio:(BOOL)rad NS_DESIGNATED_INITIALIZER;

/**---------------------------------------------------------------------------------------
 * @name Post Initialization
 *  ---------------------------------------------------------------------------------------
 */

/** Sets up the button to receive touch events. 
 @discussion Must be called after the button is added to a superview.
 */
- (void)setButtonSuperview;


/**---------------------------------------------------------------------------------------
 * @name Rendering
 *  ---------------------------------------------------------------------------------------
 */

/** Renders the button.
 @param frame The frame to render in
 @param ctx The context to use for rendering
 @param back YES if a background should be rendered
 @param selected YES if the button is selected
 @param radio YES is the button is a radio type button
 */
+ (void)drawWithRect:(CGRect)frame context:(CGContextRef)ctx back:(BOOL)back selected:(BOOL)selected radio:(BOOL)radio;


@end


NS_ASSUME_NONNULL_END
