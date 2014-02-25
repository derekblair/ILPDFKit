//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>



/** The PDFObjectParser class converts a string representation of a PDF object into
a series of tokens representing object components of the represented object. The tokens may be 
keys and values in the case of a dictionary or elements of an array, for example. PDFObjectParser makes no assumptions
about, the type of the PDF object represented in str.
As an example:
 
     NSString* dictionaryString = @"<</Key1 (value1) /Key2 (value2) /Key3 [32 /aname]>>"
     PDFObjectParser* parser = [PDFObjectParser parserWithString:dictionaryString Parent:parentDocument];
     NSMutableArray* keysAndValues = [NSMutableArray array];
     
     for(id token in parser)
     {
        [keysAndValues addObject:token];
     }
     // From here we can extract all keys and corresponding values using the NSArray
 
 PDFObjectParser is not meant to replace the Core Graphics PDF functions but rather provide of means of extracting more data related to the PDF file structure such as specific object and generation numbers.
 */

@class PDFDocument;

@interface PDFObjectParser : NSObject<NSFastEnumeration>


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFObjectParser
 *  ---------------------------------------------------------------------------------------
 */


/** Initializes with a string to parse
 
 @param strg The string to parse.
 @return self.
 */
-(id)initWithString:(NSString*)strg;


/** Creates an autoreleased instance of PDFObjectParser initialized with a string.
 
 @param strg The string to parse.
 @return An instance of PDFObjectParser.
 */
+(PDFObjectParser*)parserWithString:(NSString*)strg;

@end
