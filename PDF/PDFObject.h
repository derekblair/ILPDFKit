

#import <Foundation/Foundation.h>

@class PDFDocument;

/** This class represents an abstract base class from which all PDF object classes inherit from.
It should not be directly instantiated.
PDF Objects are represented by PDFObject subclasses as follows
 
Array becomes PDFArray
Dictionary becomes PDFDictionary
Stream becomes PDFStream
 
And other types are represented as follows
 
Name becomes PDFName
String becomes NSString
Real becomes NSNumber
Integer becomes NSNumber
Boolean becomes NSNumber
Null becomes nil
 
Note that Strings and Numbers may be presented as generic PDFObject instances in the case when they are indirect objects.
 */

@interface PDFObject : NSObject 
{
    NSUInteger _objectNumber;
    NSInteger _generationNumber;
    NSString* representation;
}


/**
 The object number is an indirect object
 */
@property(nonatomic) NSUInteger objectNumber;

/**
 The generation number is an indirect object. Else -1
 */
@property(nonatomic) NSInteger generationNumber;



/**
 Initializes a pdf object based on a string representation of that object.
 @param rep The string representation of the PDF object from the parent document.
 @return The representation of the object as it is defined in its parent document.
 */

-(id)initWithPDFRepresentation:(NSString*)rep ;


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
 @return The string representation of the object as it is defined in the PDF standard.
 */
-(NSString*)pdfFileRepresentation;


/**
 For objects with only reference numbers and no representation, looks up the representation in the cross reference table
 belonging to document and sets it as representation.
 @param document The document cooresponding to the cross reference table in which to look up the reference
 */

-(void)dereferenceWithDocument:(PDFDocument*)document;


@end
