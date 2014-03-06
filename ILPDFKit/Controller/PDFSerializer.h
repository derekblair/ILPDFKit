//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <Foundation/Foundation.h>

/**
    The PDFSerialzer class encapsulates the task of saving the changes in a PDF, such as form value changes, to the source PDF file itself.
 The file can then easily to be written to disk or sent over the internet with the changes intact. This class is a static class.
 */
@interface PDFSerializer : NSObject


/** Attempts to save any changes in the PDF forms of a document to the document itself.
 
 @param baseData The data that represents the PDF file you are saving to.
 @param forms The collection of forms that contain the changes to save if they exist.
 @param completion Called after the save operation has completed.
 */
+(void)saveDocumentChanges:(NSMutableData*)baseData basedOnForms:(id<NSFastEnumeration>)forms  completion:(void (^)(BOOL success))completion;
@end
