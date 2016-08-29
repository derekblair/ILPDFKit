// ILPDFFormTextField.h
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

/** The ILPDFFormTextField represents a view for a PDF text field.
 */
@interface ILPDFFormTextField : ILPDFWidgetAnnotationView 


/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFFormTextField
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of ILPDFFormTextField
 
 @param frame The new view's frame.
 @param multiline YES if multiple lines are permitted, otherwise NO.
 @param alignment The alignment for the text.
 @param secureEntry YES if field text should be hidden as in a password field, otherwise NO.
 @param ro YES if field is read only, otherwise NO.
 @return A new ILPDFFormTextField object.
 */
- (instancetype)initWithFrame:(CGRect)frame multiline:(BOOL)multiline alignment:(NSTextAlignment)alignment secureEntry:(BOOL)secureEntry readOnly:(BOOL)ro NS_DESIGNATED_INITIALIZER;


@end


NS_ASSUME_NONNULL_END
