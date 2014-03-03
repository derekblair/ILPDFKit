//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>
#import "PDFObject.h"

/** The PDFArray class encapsulates a PDF array object contained in a PDFDocument.
 Essentially, is is a wrapper class for a CGPDFArrayRef.
 
     CGPDFArrayRef pdfARef = myCGPDFArrayRef;
     PDFArray* pdfArray = [[PDFArray alloc] initWithArray:pdfARef];
 
 PDFArray provides a range of methods that mirror those of NSArray.
 */

@interface PDFArray : PDFObject<NSFastEnumeration>



/** The NSArray backing store.
 @discussion PDFArray maps the CGPDFArray arr onto the NSArray nsa. Thus nsa contains all the information of its owning PDFArray.
 */
@property(nonatomic,readonly) NSArray* nsa;

/** The CGPDFDictionaryRef that defines the dictionary.
 
 */
@property(nonatomic,readonly) CGPDFArrayRef arr;



/**---------------------------------------------------------------------------------------
 * @name Creating a PDFArray
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFArray wrapping a CGPDFArrayRef
 
 @param parr A CGPDFArrayRef representing the PDF array.
 @return A new PDFArray object. Initialization in memory occurs when the instance receives value based query.
 */
-(id)initWithArray:(CGPDFArrayRef)parr;



/**---------------------------------------------------------------------------------------
 * @name Getting Object Type
 *  ---------------------------------------------------------------------------------------
 */

/** Returns the CPDFObjectType associated with the PDF object at index aIndex.
 
 @param aIndex The key for which to return the corresponding type.
 @return The type of the value associated with aIndex, or kCGPDFObjectTypeNull if no value is associated with aIndex.
 */



/**---------------------------------------------------------------------------------------
 * @name Rectangle Arrays
 *  ---------------------------------------------------------------------------------------
 */

/** Returns the rectangle when the array is interpreted as a rectangle array.
 @return The CGRect corresponding to the retangle array.
 @discussion A 'Rect' array is a PDF Array that specifies a rectangle on page in default user space units. It consists of 4 real numbers that may be negative or positive and typically has a 'Rect' key when obtained from a parent PDFDictionary.
 The CGRect returned specifies the same rectangle in user space units only it has it's origin at top left like a retangle on a UIView. The 'Rect' PDFArray has a format [left, bottom, right, top] and the return rect is obtained as
    CGRectMake(MIN(left,right),MIN(bottom,top),fabsf(right-left),fabsf(top-bottom))
    
 */
-(CGRect)rect;


/**---------------------------------------------------------------------------------------
 * @name Accessing Values
 *  ---------------------------------------------------------------------------------------
 */


/** Returns the value associated with a given index.
 
 @param aIndex The index for which to return the corresponding value
 @return The value associated with aIndex, or nil if no value is associated with aIndex.
 */
-(id)objectAtIndex:(NSUInteger)aIndex;



/** Returns the first object.
 
 @return The first object or nil if the array is empty.
 */
-(id)firstObject;



/** Returns the last object.
 
 @return The last object or nil if the array is empty.
 */
-(id)lastObject;


/**---------------------------------------------------------------------------------------
 * @name Counting Entries
 *  ---------------------------------------------------------------------------------------
 */


/** Returns the number of elements in the array.
 
 @return The number of elements in the array.
 */
-(NSUInteger)count;


/**---------------------------------------------------------------------------------------
 * @name Comparing Arrays
 *  ---------------------------------------------------------------------------------------
 */

/** Returns a Boolean value that indicates whether the contents of the receiving array are equal to the contents of another given array.
 @param otherArray The array with which to compare the receiving array.
 @return YES if the contents of otherArray are equal to the contents of the receiving array, otherwise NO.
 @discussion Two arrays have equal contents if they each hold the same number of objects and objects at a given index in each array satisfy the isEqual: test.
 */
-(BOOL)isEqualToArray:(PDFArray*)otherArray;





@end
