// ILPDFArray.h
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
#import "ILPDFObject.h"

NS_ASSUME_NONNULL_BEGIN

/** The ILPDFArray class encapsulates a PDF array object contained in a ILPDFDocument.
 Essentially, is is a wrapper class for a CGPDFArrayRef.
 
     CGPDFArrayRef pdfARef = myCGPDFArrayRef;
     ILPDFArray* pdfArray = [[ILPDFArray alloc] initWithArray:pdfARef];
 
 ILPDFArray provides a range of methods that mirror those of NSArray. ILPDFArray may also
 be instantiated based on a string representation of its contents without needing to be assoicated with
 a parent document.
 */

@interface ILPDFArray : NSObject <NSFastEnumeration, ILPDFObject>

/**
 The Core Graphics array reference, if it exists.
 */
@property (nonatomic, readonly, nullable) CGPDFArrayRef arr;

/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFArray
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of ILPDFArray wrapping a CGPDFArrayRef
 @param parr A CGPDFArrayRef representing the PDF array.
 @return A new ILPDFArray object. Initialization in memory occurs when the instance receives value based query.
 */
- (instancetype)initWithArray:(CGPDFArrayRef)parr NS_DESIGNATED_INITIALIZER;

/**---------------------------------------------------------------------------------------
 * @name Rectangle Arrays
 *  ---------------------------------------------------------------------------------------
 */

/** Returns the rectangle when the array is interpreted as a rectangle array.
 @return The NSValue boxed CGRect corresponding to the retangle array or nil of the array is invalid.
 @discussion A 'Rect' array is a PDF Array that specifies a rectangle on page in default user space units. It consists of 4 real numbers that may be negative or positive and typically has a 'Rect' key when obtained from a parent ILPDFDictionary.
 The CGRect returned specifies the same rectangle in user space units only it has its origin at top left like a rectangle on a UIView. The 'Rect' ILPDFArray has a format [left, bottom, right, top] and the return rect is obtained as
    CGRectMake(MIN(left,right),MIN(bottom,top),fabsf(right-left),fabsf(top-bottom))
 */
- (nullable NSValue *)rect;

/**---------------------------------------------------------------------------------------
 * @name Accessing Values
 *  ---------------------------------------------------------------------------------------
 */

/** Returns the value associated with a given index.
 @param index The index for which to return the corresponding value
 @return The value associated with index, or nil if no value is associated with index.
 */
- (nullable id)objectAtIndex:(NSUInteger)index;

/** Returns the first object.
 @return The first object or nil if the array is empty.
 */
-(nullable id)firstObject;

/** Returns the last object.
 @return The last object or nil if the array is empty.
 */
-(nullable id)lastObject;

/**---------------------------------------------------------------------------------------
 * @name Counting Entries
 *  ---------------------------------------------------------------------------------------
 */

/** Returns the number of elements in the array.
 @return The number of elements in the array.
 */
- (NSUInteger)count;

/**---------------------------------------------------------------------------------------
 * @name Comparing Arrays
 *  ---------------------------------------------------------------------------------------
 */

/** Returns a Boolean value that indicates whether the contents of the receiving array are equal to the contents of another given array.
 @param otherArray The array with which to compare the receiving array.
 @return YES if the contents of otherArray are equal to the contents of the receiving array, otherwise NO.
 @discussion Two arrays have equal contents if they each hold the same number of objects and objects at a given index in each array satisfy the isEqual: test.
 */
- (BOOL)isEqualToArray:(ILPDFArray *)otherArray;

////// This class supports indexed subscripting as in id<ILPDFObject> obj = pdfArray[index];

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;

@end


NS_ASSUME_NONNULL_END
