

#import <Foundation/Foundation.h>

@interface NSString(PDF)

    -(BOOL)isName;
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
 
 - Name becomes NSString
 - String becomes NSString
 - Real becomes NSNumber
 - Integer becomes NSNumber
 - Boolean becomes NSNumber
 - Null becomes nil
 
Note that Strings and Numbers may be presented as generic PDFObject instances in the case when they are indirect objects.
 */

@interface PDFObject : NSObject<NSCopying>


/**
 The object number if instance is an indirect object
 */
//@property(nonatomic) NSUInteger objectNumber;

/**
 The generation number if instance is an indirect object. Else -1
 */
//@property(nonatomic) NSInteger generationNumber;

/**
 The parent document.
 */
//@property(nonatomic,readonly) PDFDocument* parentDocument;


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFObject
 *  ---------------------------------------------------------------------------------------
 */

/**
 Initializes a pdf object based on a string representation of that object.
 @param rep The string representation of the PDF object from the parent document.
@param parentDocument The parent document containing the object.
 @return The representation of the object as it is defined in its parent document.
 */

-(id)initWithPDFRepresentation:(NSString*)rep; //Document:(PDFDocument*)parentDocument;


/**
 Creates a new pdf object based on an object number, generation number and containing document.  Looks up the representation in the cross reference table.
 @param objNumber The object number of the PDF object.
 @param genNumber The generation number of the PDF object.
 @param parentDocument The parent document containing the object.
 @return The representation of the object as it is defined in its parent document.
 */

//+(PDFObject*)createWithObjectNumber:(NSUInteger)objNumber GenerationNumber:(NSUInteger)genNumber Document:(PDFDocument*)parentDocument;


/**
 Creates a new pdf object based on a string representation of that object.
 @param rep The string representation of the PDF object from the parent document.
 @param parentDocument The parent document containing the object.
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
 @return The ASCII string representation of the object.
 */
-(NSString*)pdfFileRepresentation;




@end
