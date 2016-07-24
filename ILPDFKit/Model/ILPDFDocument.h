// ILPDFDocument.h
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
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>


/** ILPDFDocument represents a PDF document either loaded from file or disk. The class provides tools to reveal the structure, content and metadata of a PDF. ILPDFDocument serves as the model for ILPDFViewController to render an interactive PDF on a ILPDFView.
 */

@class ILPDFDictionary;
@class ILPDFFormContainer;

NS_ASSUME_NONNULL_BEGIN

@interface ILPDFDocument : NSObject

/** The PDF file data.
 */
@property (nonatomic, strong, null_resettable) NSMutableData *documentData;

/** The form container holding the forms for the document.
 */
@property (nonatomic, readonly, null_resettable) ILPDFFormContainer *forms;

/** The path for the PDF document if it was loaded from file.
 @discussion If the document was loaded from memory, documentPath is nil.
 */
@property (nonatomic, readonly, nullable) NSString *documentPath;

/** The document catalog for the PDF.
 @discussion See 3.6.1 in 'PDF Reference Second Edition version 1.3, Adobe Systems Incorporated'.
 */
@property (nonatomic, readonly, null_resettable) ILPDFDictionary *catalog;

/** The document info dictionary
 */
@property (nonatomic, readonly, null_resettable) ILPDFDictionary *info;

/** An array containing ILPDFPage objects cooresponding in order and content to the pages of the document.
 */
@property (nonatomic, readonly, null_resettable) NSArray *pages;

/** The name of the PDF.
 */
@property (nonatomic, strong) NSString *pdfName;

/** The CGPDFDocument on top of which the class is built.
 */
@property (nonatomic, readonly) CGPDFDocumentRef document;


/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFDocument
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of ILPDFDocument.
 
 @param data Content of the document.
 @return A new instance of ILPDFDocument initialized with data.
 */

- (instancetype)initWithData:(NSData *)data NS_DESIGNATED_INITIALIZER;

/** Creates a new instance of ILPDFDocument.
 
 @param name Resource to load.
 @return A new instance of ILPDFDocument initialized with a PDF resource named name.
 */
- (instancetype)initWithResource:(NSString *)name NS_DESIGNATED_INITIALIZER;

/** Creates a new instance of ILPDFDocument.
 
 @param path Points to PDF file to load.
 @return A new instance of ILPDFDocument initialized with a PDF located at path.
 */
- (instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

/**---------------------------------------------------------------------------------------
 * @name Finding Document Structure
 *  ---------------------------------------------------------------------------------------
 */
/** Returns the number of pages in the document.
 
 @return The page count.
 */
- (NSUInteger)numberOfPages;

/**---------------------------------------------------------------------------------------
 * @name Saving and Refreshing
 *  ---------------------------------------------------------------------------------------
 */

/** Reloads everything based on documentData.
 */
- (void)refresh;

/** Flattens the interactive elements, rendering the form values directly in the PDF. 
 Useful for saving a PDF with forms that have been filled out.
 @return The data for the static flattened PDF.
 */
- (NSData *)savedStaticPDFData;

/**
 @param docToAppend
 @return The PDF data of the result when the passed document is appended to the receiver.
 */
- (NSData *)mergedDataWithDocument:(ILPDFDocument *)docToAppend;

/**
 Converts a PDF page to an image.
 @param page The page number. 1 is the first page.
 @param width The desired width of the returned image. The image will match the aspect ratio of the page.
 @return A UIImage representing the page.
 */

- (UIImage *)imageFromPage:(NSUInteger)page width:(NSUInteger)width;

/** Sets the background color for the PDF view.
 @return A string containing an xml representation of the forms of the document and their values. Used for submitting the form.
 */
- (NSString *)formXML;

@end

NS_ASSUME_NONNULL_END
