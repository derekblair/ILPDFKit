//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>

@class PDFForm;
@class PDFDictionary;



/** The PDFFormAction class represents a script attached to a specific PDFForm, configured to execute in response to a certain user action.
 */

@interface PDFFormAction : NSObject


/** The action AcroScript.
 */
@property(nonatomic,strong) NSString* string;


/** The parent PDFForm
 */
@property(nonatomic,weak) PDFForm* parent;


/** A javascript string to add to the execution environment before string is executed.
 */
@property(nonatomic,strong) NSString* prefix;

/** Defines the context of user interaction in which the action is to be triggered.
 @discussion
 The supported  keys are:
 
 - A: Performed when a button is pressed or a text field starts editing or a choice field is expanded.
 - K: Performed when a text field is edited or a choice field selection is modified.
 - E: Performed when a text field starts editing or a choice field is expanded.
 
 */
@property(nonatomic,strong) NSString* key;

/**---------------------------------------------------------------------------------------
 * @name Creating a PDFFormAction
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFFormAction based on a PDF action dictionary
 
 @param dict A PDFDictionary based on the action dictionary that defines the action.
 @return A new PDFFormAction object.
 */
-(id)initWithActionDictionary:(PDFDictionary*)dict;


/**---------------------------------------------------------------------------------------
 * @name Execution
 *  ---------------------------------------------------------------------------------------
 */


/** Executes the AcroScript defining the action and subsequently updates any resulting state changes to the PDFFormContainer.
 */
-(void)execute;

@end


