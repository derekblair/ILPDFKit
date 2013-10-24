

#import <Foundation/Foundation.h>
#import "PDFForm.h"

@class PDFForm;
@class PDFDocument;


/** The PDFFormContainer class represents a container class for all the PDFForm objects attached to a PDFDocument. It manages the Adobe AcroScript execution environment as well as the UIKit representation of a PDFForm.
 */
@interface PDFFormContainer : NSObject<UIWebViewDelegate,NSFastEnumeration>
{
    
    NSMutableArray* formsByType[PDFFormTypeNumberOfFormTypes];
    NSMutableArray* allForms;
    NSMutableDictionary* nameTree;
    PDFDocument* document;
    UIWebView* jsParser;
}


/** The parent PDFDocument.
 */
@property(nonatomic,assign) PDFDocument* document;

/**---------------------------------------------------------------------------------------
 * @name Creating a PDFFormContainer
 *  ---------------------------------------------------------------------------------------
 */



/** Creates a new instance of PDFFormContainer
 
 @param parent The PDFDocument that owns the PDFFormContainer.
 @return A new PDFFormContainer object.
 */
-(id)initWithParentDocument:(PDFDocument*)parent;



/**---------------------------------------------------------------------------------------
 * @name Retrieving Forms
 *  ---------------------------------------------------------------------------------------
 */


/** Returns all forms with called by name
 
 @param name The name to filter by.
 @return An array of the filtered forms.
 */
-(NSArray*)formsWithName:(NSString*)name;


/** Returns all forms with called by type
 
 @param type The type to filter by.
 @return An array of the filtered forms.
 @discussion Here are the possible types:
 
 PDFFormTypeNone: An unknown form type.
 PDFFormTypeText: A text field, either multiline or singleline.
 PDFFormTypeButton: A radio button, combo box buttton, or push button.
 PDFFormTypeChoice: A combo box.
 PDFFormTypeSignature: A signature form.
 */
-(NSArray*)formsWithType:(PDFFormType)type;


/**---------------------------------------------------------------------------------------
 * @name Adding and Removing Forms
 *  ---------------------------------------------------------------------------------------
 */

/** Adds a form to the container
 @param form The form to add.
 */
-(void)addForm:(PDFForm*)form;

/** Removes a form from the container
 @param form The form to remove.
 */
-(void)removeForm:(PDFForm*)form;




/**---------------------------------------------------------------------------------------
 * @name Getting Visual Representations
 *  ---------------------------------------------------------------------------------------
 */

/** Returns an array of UIView based objects representing the forms.
 
 @param width The width of the superview to add the resulting views as subviews.
 @param margin The margin of the superview to add the resulting views as subviews.
 @return An NSArray containing the resulting views. You are responsible for releasing the array.
 */
-(NSArray*)createUIAdditionViewsForSuperviewWithWidth:(CGFloat)width Margin:(CGFloat)margin;




/**---------------------------------------------------------------------------------------
 * @name Setting Values
 *  ---------------------------------------------------------------------------------------
 */

/** Sets a form value.
 @param val The value to set.
 @param name The name of the form(s) to set the value for. 
 */
-(void)setValue:(NSString*)val ForFormWithName:(NSString*)name;




/**---------------------------------------------------------------------------------------
 * @name Script Execution
 *  ---------------------------------------------------------------------------------------
 */


/** Executes a script.
 @param js The script to execute.
 @discussion The script only modifies PDFFormObjects in value or options.
 */
-(void)executeJS:(NSString*)js;


/** Sets a value/key pair for the script execution environment.
 @param value The value.
 @param key The key.
 @discussion This is implemented using HTML5 localStorage.
 */
-(void)setHTML5StorageValue:(NSString*)value ForKey:(NSString*)key;


/** Gets a value based on a key from the script execution environment.
 @param key The key.
 @return The value associated with key. If no value exists, returns nil.
 @discussion This is implemented using HTML5 localStorage.
 */
-(NSString*)getHTML5StorageValueForKey:(NSString*)key;




/**---------------------------------------------------------------------------------------
 * @name XML 
 *  ---------------------------------------------------------------------------------------
 */

/** Returns an XML representation of the form values in the document.
 @return The xml string defining the value and hierarchical structure of all forms in the document.
 */
-(NSString*)formXML;




@end
