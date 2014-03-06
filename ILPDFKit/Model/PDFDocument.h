//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>


/** PDFDocument represents a PDF document either loaded from file or disk. The class provides tools to reveal the structure, content and metadata of a PDF. PDFDocument serves as the model for PDFViewController to render an interactive PDF on a PDFView.
 */

@class PDFDictionary;
@class PDFFormContainer;

@interface PDFDocument : NSObject


/** The PDF file data.
 */
@property(nonatomic,strong) NSMutableData* documentData;

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
//@property(nonatomic,readonly) PDFDictionary* info;

/** An array containing PDFPage objects cooresponding in order and content to the pages of the document.
 */
@property(nonatomic,readonly) NSArray* pages;


/** The name of the PDF.
 */
@property(nonatomic,strong) NSString* pdfName;

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


/** Saves any changes in the PDF forms to its data. Must be PDF 1.3 compliant.
 Call writeToFile to subsequently save the updated PDF to disk.
 @param completion Called after completion with a variable indicating success or failure.
 */
-(void)saveFormsToDocumentData:(void (^)(BOOL success))completion;



/** Reloads everything based on documentData.
 */
-(void)refresh;



/** Writes to file.
 @param name The path of the file to write to.
 */
-(void)writeToFile:(NSString*)name;

/** Flattens the interactive elements, rendering the form values directly in the PDF. Useful for saving the PDF.
 @return The data for the static flattened PDF.
 */
-(NSData*)flattenedData;


/**
 Converts a PDF page to an image.
 @param page The page number. 1 is the first page.
 @param width The desired width of the returned image. The image will match the aspect ratio of the page.
 @return A UIImage representing the page.
 */

-(UIImage*)imageFromPage:(NSUInteger)page width:(NSUInteger)width;


/** Sets the background color for the PDF view.
 @return A string containing an xml representation of the forms of the document and their values. Used for submitting the form.
 */
-(NSString*)formXML;






@end
