

#import <UIKit/UIKit.h>
#import "PDFUIAdditionElementView.h"


/** The PDFFormTextField represents a view for a PDF text field.
 */
@interface PDFFormTextField : PDFUIAdditionElementView<UITextViewDelegate,UITextFieldDelegate>


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFFormTextField
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFFormTextField
 
 @param frame The new view's frame.
 @param multiline YES if multiple lines are permitted, otherwise NO.
 @param alignment The alignment for the text.
 @param secureEntry YES if field text should be hidden as in a password field, otherwise NO.
 @param ro YES if field is read only, otherwise NO.
 @return A new PDFFormTextField object.
 */
-(id)initWithFrame:(CGRect)frame Multiline:(BOOL)multiline Alignment:(UITextAlignment)alignment SecureEntry:(BOOL)secureEntry ReadOnly:(BOOL)ro;


@end
