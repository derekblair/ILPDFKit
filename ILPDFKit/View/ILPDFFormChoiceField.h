// ILPDFFormChoiceField.h
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


/** The ILPDFFormChoiceField represents a view for a PDF choice field.
 */
@interface ILPDFFormChoiceField : ILPDFWidgetAnnotationView 


/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFFormChoiceField
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of ILPDFFormChoiceField 
 
 @param frame The new view's frame.
 @param opt An array of NSString obejcts representing the choices for the field.
 @return A new ILPDFFormChoiceField object. 
 */
- (instancetype)initWithFrame:(CGRect)frame options:(NSArray *)opt NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
