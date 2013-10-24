

#import <Foundation/Foundation.h>


/** PDFDocument represents a PDF document either loaded from file or disk. The class provides tools to reveal the structure, content and metadata of a PDF. PDFDocument serves as the model for PDFViewController to render an interactive PDF on a PDFView.
 */

@class PDFDictionary;
@class PDFFormContainer;

@interface PDFDocument : NSObject
{
    CGPDFDocumentRef document;
    NSMutableData* documentData;
   
    NSMutableString* sourceCode;
    NSString* documentPath;
    PDFDictionary* catalog;
    PDFDictionary* info;
    PDFFormContainer* forms;
    NSArray* pages;
    NSString* pdfName;
}







/** The PDF file data.
 */
@property(nonatomic,retain) NSMutableData* documentData;

/** The form container holding the forms for the document.
 */
@property(nonatomic,readonly) PDFFormContainer* forms;


/** The path for the PDF document if it was loaded from file.
 @discussion If the document was loaded from memory, documentPath is nil.
 */
@property(nonatomic,readonly) NSString* documentPath;


/** The document catalog for the PDF.
 @discussion See 3.6.1 in 'PDF Reference Second Edition version 1.3, Adobe Systems Incorporated'.
 */
@property(nonatomic,readonly) PDFDictionary* catalog;

/** The document info dictionary
 */
@property(nonatomic,readonly) PDFDictionary* info;

/** An array containing PDFPage objects cooresponding in order and content to the pages of the document.
 */
@property(nonatomic,readonly) NSArray* pages;


/** The name of the PDF.
 */
@property(nonatomic,retain) NSString* pdfName;

/** The CGPDFDocument on top of which the class is built.
 */
@property(nonatomic,readonly) CGPDFDocumentRef document;


/**---------------------------------------------------------------------------------------
 * @name Creating a PDFDocument
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of PDFDocument.
 
 @param data Content of the document.
 @return A new instance of PDFDocument initialized with data.
 */

-(id)initWithData:(NSData*)data;

/** Creates a new instance of PDFDocument.
 
 @param name Resource to load.
 @return A new instance of PDFDocument initialized with a PDF resource named name.
 */
-(id)initWithResource:(NSString*)name;

/** Creates a new instance of PDFDocument.
 
 @param path Points to PDF file to load.
 @return A new instance of PDFDocument initialized with a PDF located at path.
 */
-(id)initWithPath:(NSString*)path;


/**---------------------------------------------------------------------------------------
 * @name Finding Document Structure
 *  ---------------------------------------------------------------------------------------
 */
/** Returns the number of pages in the document.
 
 @return The page count.
 */
-(NSUInteger)numberOfPages;



/**---------------------------------------------------------------------------------------
 * @name Saving and Refreshing
 *  ---------------------------------------------------------------------------------------
 */


/** Saves any changes in the PDF forms to it's data.
 Call writeToFile to subsequently save the updated PDF to disk.
 @return YES if successful, NO is failed.
 */
-(BOOL)saveFormsToDocumentData;



/** Reloads everything based on documentData.
 */
-(void)refresh;



/** Writes to file.
 @param name The path of the file to write to.
 */
-(void)writeToFile:(NSString*)name;


/**
 Looks up an object in the cross-reference table
 @param objectNumber The object number of the object to find
 @param generationNumber The generation number of the object to find
 @return The file represention of the object including the the obj and endobj bounding lines.
 */


-(NSString*)codeForObjectWithNumber:(NSInteger)objectNumber GenerationNumber:(NSInteger)generationNumber;





@end
