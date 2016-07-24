// ILPDFFormContainer.h
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
#import "ILPDFForm.h"


@class ILPDFDocument;
@class ILPDFView;

NS_ASSUME_NONNULL_BEGIN

/** The ILPDFFormContainer class represents a container class for all the ILPDFForm objects attached to a ILPDFDocument.
 */
@interface ILPDFFormContainer : NSObject <NSFastEnumeration>

/** The parent ILPDFDocument.
 */
@property (nonatomic, weak) ILPDFDocument *document;

/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFFormContainer
 *  ---------------------------------------------------------------------------------------
 */
/** Creates a new instance of ILPDFFormContainer
 @param parent The ILPDFDocument that owns the ILPDFFormContainer.
 @return A new ILPDFFormContainer object.
 */
- (instancetype)initWithParentDocument:(ILPDFDocument *)parent NS_DESIGNATED_INITIALIZER;

/**---------------------------------------------------------------------------------------
 * @name Retrieving Forms
 *  ---------------------------------------------------------------------------------------
 */


/** Returns all forms with called by name
 
 @param name The name to filter by.
 @return An array of the filtered forms.
 @discussion Generally this will return an array with a single
 object. When multiple forms have the same name, their values are kept
 the same because they are treated as logically the same entity with respect 
 to a name-value pair. For example, a choice form called
 'City' may be set as 'Lusaka' by the user on page 1, and another choice form
 also called 'City' on a summary page at the end will also be synced to have the
 value of 'Lusaka'. This is in conformity with the PDF standard. Another common relevent scenario
 involves mutually exclusive radio button/check box groups. Such groups are composed of multiple forms
 with the same name. Their common value is the exportValue of the selected button. If the value is equal 
 to the exportValue for such a form, it is checked. In this way, it is easy to see as well why such
 groups are mutually exclusive. Buttons with distinct names are not mutually exclusive, 
 that is they don't form a radio button group.
 */
- (NSArray *)formsWithName:(NSString *)name;


/** Returns all forms with called by type
 
 @param type The type to filter by.
 @return An array of the filtered forms.
 @discussion Here are the possible types:
 
 ILPDFFormTypeNone: An unknown form type.
 ILPDFFormTypeText: A text field, either multiline or singleline.
 ILPDFFormTypeButton: A radio button, combo box buttton, or push button.
 ILPDFFormTypeChoice: A combo box.
 ILPDFFormTypeSignature: A signature form.
 */
- (NSArray *)formsWithType:(ILPDFFormType)type;



/**---------------------------------------------------------------------------------------
 * @name Getting Visual Representations
 *  ---------------------------------------------------------------------------------------
 */

/** 
 Updates the widget views.
 */
- (void)updateWidgetAnnotationViews:(NSMapTable *)pageViews views:(NSMutableArray *)views  pdfView:(ILPDFView *)pdfView;


/**---------------------------------------------------------------------------------------
 * @name Setting Values
 *  ---------------------------------------------------------------------------------------
 */

/** Sets a form value.
 @param val The value to set.
 @param name The name of the form(s) to set the value for. 
 */
- (void)setValue:(nullable NSString *)val forFormWithName:(NSString *)name;

/**---------------------------------------------------------------------------------------
 * @name XML 
 *  ---------------------------------------------------------------------------------------
 */

/** Returns an XML representation of the form values in the document.
 @return The xml string defining the value and hierarchical structure of all forms in the document.
 */
- (NSString *)formXML;


@end


NS_ASSUME_NONNULL_END
