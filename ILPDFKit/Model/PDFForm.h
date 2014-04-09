//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>
#import "PDFWidgetAnnotationView.h"




#define BIT(n,i) (((i)>>(n))&1)


typedef NS_ENUM(NSUInteger, PDFFormType) {
    PDFFormTypeNone = 0,
    PDFFormTypeText,
    PDFFormTypeButton,
    PDFFormTypeChoice,
    PDFFormTypeSignature,
    PDFFormTypeNumberOfFormTypes
};


@class PDFFormContainer;
@class PDFPage;
@class PDFDictionary;
@class PDFUIElement;
@class PDFWidgetAnnotationView;



/** The PDFForm class represents a Widget Annotation owned by an interactive PDF form corresponding to a Field Dictionary contained in the 'Fields' array of the document's 'AcroForm' dictionary. Thus each instance of PDFForm represents a unique rectangle on the PDF document where user interaction is permitted, whether through pressing or typing text. A 'Field' is a collection of PDFForm with the same name. All forms in a field have the same value. A 'Field' represents a coherent group of forms that work together to present and collect a common unified piece of information. For example a field may consist of the two button forms named 'Sex' and marked 'Male' and 'Female' respectively to collect the information of a person's gender. A form can create a UIView representation of itself that can respond to user interaction.
 
 PDFChoiceField* comboBox = [comboBoxTypeForm createWidgetAnnotationViewForSuperviewWithWidth:webView.bounds.size.width  Margin:9.5];
 [webView.scrollView addSubview comboBox];
 [comboBox release];
 */
@interface PDFForm : NSObject<PDFWidgetAnnotationViewDelegate>

/** The value of the form.
 */
@property(nonatomic,strong) NSString* value;

/** The page number on which the form appears. The first page has value 1.
 */
@property(nonatomic) NSUInteger page;

/** The rect in points obtained from the 'Rect' rectangle array and applying -(CGRect)rect on the PDFArray
 */
@property(nonatomic) CGRect frame;

/** The form type.
 
 - PDFFormTypeNone: An unknown form type.
 - PDFFormTypeText: A text field, either multiline or singleline.
 - PDFFormTypeButton: A radio button, combo box buttton, or push button.
 - PDFFormTypeChoice: A combo box.
 - PDFFormTypeSignature: A signature form.
 
 */
@property(nonatomic) PDFFormType formType;


/** The crop box for the parent PDF page.
 */
@property(nonatomic) CGRect cropBox;


/** The media box for the parent PDF page.
 */
@property(nonatomic) CGRect mediaBox;

/** The full, period delimeted form name.
 e.g PersonalInfo.Address.PostalCode
 */
@property(nonatomic,strong) NSString* name;


/** The name of the field shown to the user
 */
@property(nonatomic,strong) NSString* uname;


/** The default value for the form.
 */
@property(nonatomic,strong) NSString* defaultValue;

/** A string containing all flags.
 Current supported flags are:
 
 - ReadOnly
 - Required
 - NoExport
 - NoToggleToOff
 - Radio
 - Pushbutton
 - Combo
 - Edit
 - Sort
 - Multiline
 - Password
 - Invisible
 - Hidden
 - Print
 - NoZoom
 - NoRotate
 - NoView
 
 */
@property(nonatomic,strong) NSString* flagsString;


/** For choice fields only, the options of the combo box.
 */
@property(nonatomic,strong) NSArray* options;

/** The intended text alignemnt for text in the form.
 */
@property(nonatomic) NSTextAlignment textAlignment;

/** The frame of the form view on its parent UIScrollView
 */
@property(nonatomic) CGRect uiBaseFrame;

/** The frame of the form view on its parent UIScrollView if all forms were on the first page
 */
@property(nonatomic) CGRect pageFrame;

/** The form container that owns the form
 */
@property(nonatomic,weak) PDFFormContainer* parent;

/** The dictionary containing all PDFFormAction actions. The keys match the corresponding key through which the action exists in it's parent PDFDictionary. The main action is under 'A' and additionaly actions are found uner 'K' and 'E'.
 */
@property(nonatomic,strong) NSMutableDictionary* actions;

/** The NSArray of NSNumber values representing the raw frame rectangle for the form.
 */
@property(nonatomic,strong) NSArray* rawRect;


/** This is used with button forms only. Gives the name of the choice represented by that button.
 @discussion If a button is part of a group of buttons where only one may be selected at once, then it's value is the exportValue of the selected button. All buttons in such a group have the same name and represent a single form conceptually. Thus all forms in a radio button or check box group represent the field and always have the same value. A button is selected if and only if its exportValue is the same as its value. If no buttons are selected, or an unselected button is single and not part of a group, then the value is nil.
 */
@property(nonatomic,strong) NSString* exportValue;


/** Indicates if the form has been modified by user input.
 */
@property(nonatomic) BOOL modified;


/** The appearance stream for the set state of button forms. Can be used to customize button appearance to better match the PDF.
 */
@property(nonatomic,strong) NSString* setAppearanceStream;


/**
 The field dictionary that defines the form
 */
@property(nonatomic,strong) PDFDictionary* dictionary;



/**---------------------------------------------------------------------------------------
 * @name Creating a PDFForm
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFForm based on a leaf AcroForm field dictionary and a PDF page
 
 @param leaf Either a terminal Acroform field dictionary (i.e. with no children), a terminal widget annotation dictionary, or a union of both. 
 If leaf is a widget annotation, the parent element of the dictionary is used to traverse up the field tree to read inherited values from its parent field dictionary.
 @param pg The page that contains the form.
 @param p The parent.
 @return A new PDFForm object. 
 */
-(id)initWithFieldDictionary:(PDFDictionary*)leaf Page:(PDFPage*)pg Parent:(PDFFormContainer*)p;


/**---------------------------------------------------------------------------------------
 * @name Updating Data
 *  ---------------------------------------------------------------------------------------
 */

/** Resets the form to defaultValue if it exists, otherwise sets value to nil.
 */
-(void)reset;


/**---------------------------------------------------------------------------------------
 * @name Rendering
 *  ---------------------------------------------------------------------------------------
 */


/** Renders the view in vector graphics within a PDF context.
 @param ctx The PDF context to render into.
 @param rect The rectangle to render on.
 */
-(void)vectorRenderInPDFContext:(CGContextRef)ctx forRect:(CGRect)rect;




/** Returns a view to represent the form.
 
 @param vwidth The width of the superview bounds.
 @param xmargin The horizonal margin width for the actual content frame in the superview.
 @param ymargin The vertical margin height for the actual content frame in the superview.
 @return A new view representing the form. The caller is responsible for releasing the new form view.
 @discussion The superview must be a UIScrollView or a subclass of UIScrollView.
 */
-(PDFWidgetAnnotationView*)createWidgetAnnotationViewForSuperviewWithWidth:(CGFloat)vwidth XMargin:(CGFloat)xmargin YMargin:(CGFloat)ymargin;


/**---------------------------------------------------------------------------------------
 * @name KVO
 *  ---------------------------------------------------------------------------------------
 */

/**
 Removes any UI elements observing the form value
 */

-(void)removeObservers;

@end


