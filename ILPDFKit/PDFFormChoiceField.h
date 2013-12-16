
#import <UIKit/UIKit.h>
#import "PDFUIAdditionElementView.h"


@class PDFFormChoiceFieldDropIndicator;


/** The PDFFormChoiceField represents a view for a PDF choice field.
 */
@interface PDFFormChoiceField : PDFUIAdditionElementView<UITableViewDelegate,UITableViewDataSource>


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFFormChoiceField
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFFormChoiceField 
 
 @param frame The new view's frame.
 @param opt An array of NSString obejcts representing the choices for the field.
 @return A new PDFFormChoiceField object. 
 */
-(id)initWithFrame:(CGRect)frame Options:(NSArray*)opt;

@end
