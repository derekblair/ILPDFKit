//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <UIKit/UIKit.h>
#import "PDFWidgetAnnotationView.h"


@class PDFFormChoiceFieldDropIndicator;


/** The PDFFormChoiceField represents a view for a PDF choice field.
 */
@interface PDFFormChoiceField : PDFWidgetAnnotationView<UITableViewDelegate,UITableViewDataSource>


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
