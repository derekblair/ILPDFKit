//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>
#import "PDFObject.h"


/** The PDFDictionary class encapsulates a PDF dictionary object contained in a PDFDocument. 
 Essentially, is is a wrapper class for a CGPDFDictionaryRef.
 
        CGPDFDictionaryRef pdfDRef = CGPDFDocumentGetCatalog(document);
        PDFDictionary* pdfDictionary = [[PDFDictionary alloc] initWithDictionary:pdfDRef];
 
 PDFDictionary provides a range of methods that mirror those of NSDictionary.
 */

@class PDFArray;

@interface PDFDictionary : PDFObject<NSFastEnumeration>


/** The NSDictionary backing store.
 @discussion PDFDictionary maps the CGPDFDictionary dict onto the NSDictionary nsd. Thus nsd contains all the information of its owning PDFDictionary except for its parent.
 */
@property(nonatomic,readonly) NSDictionary* nsd;


/** The CGPDFDictionaryRef that defines the dictionary.
 */
@property(nonatomic,readonly) CGPDFDictionaryRef dict;

/** The PDFDictionary that self is value of for some key, if it exists.
 
 @discussion If no such parent exists, parent is nil.
 */

@property(nonatomic,weak) PDFDictionary* parent;

/**---------------------------------------------------------------------------------------
 * @name Creating a PDFDictionary
 *  ---------------------------------------------------------------------------------------
 */ 

/** Creates a new instance of PDFDictionary wrapping a CGPDFDictionaryRef
 
 @param pdict A CGPDFDictionaryRef representing the PDF dictionary.
 @return A new PDFDictionary object. Initialization in memory occurs when the instance receives a key or value based query.
 */

-(id)initWithDictionary:(CGPDFDictionaryRef)pdict;


/**---------------------------------------------------------------------------------------
 * @name Accessing Keys and Values
 *  ---------------------------------------------------------------------------------------
 */


/** Returns the value associated with a given key.
 
 @param aKey The key for which to return the corresponding value
 @return The value associated with aKey, or nil if no value is associated with aKey.
 */
-(id)objectForKey:(NSString*)aKey;


/** Returns a new array containing the dictionary’s keys.
 
 @return A new array containing the dictionary’s keys, or an empty array if the dictionary has no entries.
 @discussion The order of the elements in the array is not defined.
 */
-(NSArray*)allKeys;


/** Returns a new array containing the dictionary’s values.
 
 @return A new array containing the dictionary’s values, or an empty array if the dictionary has no entries.
 @discussion The order of the elements in the array is not defined.
 */
-(NSArray*)allValues;


/**---------------------------------------------------------------------------------------
 * @name Counting Entries
 *  ---------------------------------------------------------------------------------------
 */


/** Returns the number of entries in the dictionary.
 
 @return The number of entries in the dictionary.
 */
-(NSUInteger)count;



/**---------------------------------------------------------------------------------------
 * @name Comparing Dictionaries
 *  ---------------------------------------------------------------------------------------
 */

/** Returns a Boolean value that indicates whether the contents of the receiving dictionary are equal to the contents of another given dictionary.
 @param otherDictionary The dictionary with which to compare the receiving dictionary.
 @return YES if the contents of otherDictionary are equal to the contents of the receiving dictionary, otherwise NO.
 @discussion Two dictionaries have equal contents if they each hold the same number of entries and, for a given key, the corresponding value objects in each dictionary satisfy the isEqual: test.
 */
-(BOOL)isEqualToDictionary:(PDFDictionary*)otherDictionary;




/**---------------------------------------------------------------------------------------
 * @name Updating Representations
 *  ---------------------------------------------------------------------------------------
 */


/** Returns the number of entries in the dictionary.

 @param update The dictionary to apply to an update by merging values. The passed dictionary takes precedence and passing null for a key indicates that this key should be removed.
 @return The updated representation
 */
-(NSString*)updatedRepresentation:(NSDictionary*)update;


@end
