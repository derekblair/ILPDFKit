//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>


/**
 This category is used to tell the difference between a string and a name while always using a NSString.
 */
@interface NSString(PDF)

/**
 @return YES if the receiver is obtained via the parsing of a PDF name.
 */
    -(BOOL)isName;
/**
 @param isName Used to declare the receiver to be treated as a PDF name when interacting with other PDF objects.
 */
    -(void)setAsName:(BOOL)isName;
@end




@class PDFDocument;

/** This class represents an abstract base class from which all PDF object classes inherit from.
It should not be directly instantiated.
PDF Objects are represented by PDFObject subclasses as follows
 
Array becomes PDFArray
Dictionary becomes PDFDictionary
Stream becomes PDFStream
 
And other types are represented as follows
 
 - Name becomes NSString (With isName returning YES, see category above)
 - String becomes NSString
 - Real becomes NSNumber
 - Integer becomes NSNumber
 - Boolean becomes NSNumber
 - Null becomes nil
 
Note that Strings and Numbers may be presented as generic PDFObject instances in the case when they are indirect objects.
 */

@interface PDFObject : NSObject


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFObject
 *  ---------------------------------------------------------------------------------------
 */

/**
 Initializes a pdf object based on a string representation of that object.
 @param rep The string representation of the PDF object from the parent document.
 @return The representation of the object as it is defined in its parent document.
 */

-(id)initWithPDFRepresentation:(NSString*)rep;



/**
 Creates a new pdf object based on a string representation of that object.
 @param rep The string representation of the PDF object from the parent document.
 @return The representation of the object as it is defined in its parent document.
 */

+(PDFObject*)createWithPDFRepresentation:(NSString*)rep ;


/**
 Creates a new pdf object based on a Core Graphics PDF object.
 @param obj The core graphics PDF object.
 @return A new PDF object.
 */
-(id)initWithPDFObject:(CGPDFObjectRef)obj;


/**
 @return The ASCII string representation of the object, if available.
 */
-(NSString*)pdfFileRepresentation;




@end
