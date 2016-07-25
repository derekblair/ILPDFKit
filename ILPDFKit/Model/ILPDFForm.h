// ILPDFForm.h
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

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, ILPDFAnnotationFlags) {
    ILPDFAnnotationFlagInvisible      = 1 << 0,
    ILPDFAnnotationFlagHidden         = 1 << 1,
    ILPDFAnnotationFlagPrint          = 1 << 2,
    ILPDFAnnotationFlagNoZoom         = 1 << 3,
    ILPDFAnnotationFlagNoRotate       = 1 << 4,
    ILPDFAnnotationFlagNoView         = 1 << 5,
    ILPDFAnnotationFlagReadOnly       = 1 << 6
};

typedef NS_OPTIONS(NSUInteger, ILPDFFormFlags) {
    ILPDFFormFlagReadOnly             = 1 << 0,
    ILPDFFormFlagRequired             = 1 << 1,
    ILPDFFormFlagNoExport             = 1 << 2,
    ILPDFFormFlagTextFieldMultiline   = 1 << 12,
    ILPDFFormFlagTextFieldPassword    = 1 << 13,
    ILPDFFormFlagButtonNoToggleToOff  = 1 << 14,
    ILPDFFormFlagButtonRadio          = 1 << 15,
    ILPDFFormFlagButtonPushButton     = 1 << 16,
    ILPDFFormFlagChoiceFieldIsCombo   = 1 << 17,
    ILPDFFormFlagChoiceFieldEditable  = 1 << 18,
    ILPDFFormFlagChoiceFieldSorted    = 1 << 19,
};

typedef NS_ENUM(NSUInteger, ILPDFFormType) {
    ILPDFFormTypeNone = 0,
    ILPDFFormTypeText,
    ILPDFFormTypeButton,
    ILPDFFormTypeChoice,
    ILPDFFormTypeSignature,
    ILPDFFormTypeNumberOfFormTypes
};

@class ILPDFFormContainer;
@class ILPDFPage;
@class ILPDFDictionary;
@class ILPDFWidgetAnnotationView;

NS_ASSUME_NONNULL_BEGIN

/** The ILPDFForm class represents a Widget Annotation owned by an interactive PDF form corresponding to a Field Dictionary contained in the 'Fields' array of the document's 'AcroForm' dictionary. Thus each instance of ILPDFForm represents a unique rectangle on the PDF document where user interaction is permitted, whether through pressing or typing text. A 'Field' is a collection of ILPDFForm with the same name. All forms in a field have the same value. A 'Field' represents a coherent group of forms that work together to present and collect a common unified piece of information. For example a field may consist of the two button forms named 'Sex' and marked 'Male' and 'Female' respectively to collect the information of a person's gender. A form can create a UIView representation of itself that can respond to user interaction.
 
 ILPDFChoiceField* comboBox = [comboBoxTypeForm createWidgetAnnotationViewForSuperviewWithWidth:webView.bounds.size.width  Margin:9.5];
 [webView.scrollView addSubview comboBox];
 [comboBox release];
 */
@interface ILPDFForm : NSObject 

/** The value of the form.
 */
@property (nonatomic, strong, nullable) NSString *value;

/** The page number on which the form appears. The first page has value 1.
 */
@property (nonatomic, readonly) NSUInteger page;

/** The rect in points obtained from the 'Rect' rectangle array and applying -(CGRect)rect on the ILPDFArray
 */
@property (nonatomic, readonly) CGRect frame;

/** The form type.
 
 - ILPDFFormTypeNone: An unknown form type.
 - ILPDFFormTypeText: A text field, either multiline or singleline.
 - ILPDFFormTypeButton: A radio button, combo box buttton, or push button.
 - ILPDFFormTypeChoice: A combo box.
 - ILPDFFormTypeSignature: A signature form.
 
 */
@property (nonatomic, readonly) ILPDFFormType formType;


/** The crop box for the parent PDF page.
 */
@property (nonatomic, readonly) CGRect cropBox;


/** The media box for the parent PDF page.
 */
@property (nonatomic, readonly) CGRect mediaBox;

/** The full, period delimeted form name.
 e.g PersonalInfo.Address.PostalCode
 */
@property (nonatomic, strong, readonly) NSString *name;


/** The name of the field shown to the user
 */
@property (nonatomic, strong, readonly, nullable) NSString *uname;


/** The default value for the form.
 */
@property (nonatomic, strong, readonly, nullable) NSString *defaultValue;

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
@property (nonatomic, strong, readonly, nullable) NSString *flagsString;


/** For choice fields only, the options of the combo box.
 */
@property (nonatomic, strong, nullable) NSArray *options;

/** The intended text alignemnt for text in the form.
 */
@property (nonatomic, readonly) NSTextAlignment textAlignment;

/** The frame of the form view on its parent UIScrollView
 */
@property (nonatomic, readonly) CGRect uiBaseFrame;

/** The frame of the form view on its UIPDFPageView if it was a subview
 */
@property (nonatomic, readonly) CGRect pageFrame;

/** The form container that owns the form
 */
@property (nonatomic, weak, readonly, nullable) ILPDFFormContainer *parent;


/** The NSArray of NSNumber values representing the raw frame rectangle for the form.
 */
@property (nonatomic, strong, readonly, nullable) NSArray *rawRect;


/** This is used with button forms only. Gives the name of the choice represented by that button.
 @discussion If a button is part of a group of buttons where only one may be selected at once, then it's value is the exportValue of the selected button. All buttons in such a group have the same name and represent a single form conceptually. Thus all forms in a radio button or check box group represent the field and always have the same value. A button is selected if and only if its exportValue is the same as its value. If no buttons are selected, or an unselected button is single and not part of a group, then the value is nil.
 */
@property (nonatomic, strong, readonly, nullable) NSString *exportValue;


/** Indicates if the form has been modified by user input.
 */
@property (nonatomic, readonly) BOOL modified;


/** The appearance stream for the set state of button forms. Can be used to customize button appearance to better match the PDF.
 */
@property (nonatomic, strong, readonly, nullable) NSString *setAppearanceStream;


/**
 The field dictionary that defines the form
 */
@property (nonatomic, strong, readonly, nullable) ILPDFDictionary *dictionary;

/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFForm
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of ILPDFForm based on a leaf AcroForm field dictionary and a PDF page
 
 @param leaf Either a terminal Acroform field dictionary (i.e. with no children), a terminal widget annotation dictionary, or a union of both. 
 If leaf is a widget annotation, the parent element of the dictionary is used to traverse up the field tree to read inherited values from its parent field dictionary.
 @param pg The page that contains the form.
 @param p The parent.
 @return A new ILPDFForm object. 
 */
- (instancetype)initWithFieldDictionary:(ILPDFDictionary *)leaf page:(nullable ILPDFPage *)pg parent:(nullable ILPDFFormContainer *)p NS_DESIGNATED_INITIALIZER;

/**---------------------------------------------------------------------------------------
 * @name Updating Data
 *  ---------------------------------------------------------------------------------------
 */

/** Resets the form to defaultValue if it exists, otherwise sets value to nil.
 */
- (void)reset;

/**---------------------------------------------------------------------------------------
 * @name Rendering
 *  ---------------------------------------------------------------------------------------
 */

/** Renders the view in vector graphics within a PDF context.
 @param ctx The PDF context to render into.
 @param rect The rectangle to render on.
 */
- (void)vectorRenderInPDFContext:(CGContextRef)ctx forRect:(CGRect)rect;

/** Returns a view to represent the form.
 
 @param vwidth The width of the superview bounds.
 @return A new view representing the form.
 */
- (ILPDFWidgetAnnotationView *)createWidgetAnnotationViewForPageView:(UIView *)pageView;

/**---------------------------------------------------------------------------------------
 * @name KVO
 *  ---------------------------------------------------------------------------------------
 */

/**
 Removes any UI elements observing the form value
 */

- (void)removeObservers;


/**---------------------------------------------------------------------------------------
 * @name Associated Widget
 *  ---------------------------------------------------------------------------------------
 */

/**
 The widget associated with the form , if it exists.
 */

- (nullable ILPDFWidgetAnnotationView *)associatedWidget;


/**
 Update frames.
 */
- (void)updateFrameForPDFPageView:(UIView *)pdfPage;

@end

NS_ASSUME_NONNULL_END


