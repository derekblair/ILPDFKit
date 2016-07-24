// ILPDFStream.h
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
#import "ILPDFObject.h"

NS_ASSUME_NONNULL_BEGIN
/** The ILPDFStream class encapsulates a PDF stream object contained in a ILPDFDocument.
 Essentially, is is a wrapper class for a CGPDFStreamRef.
 
    CGPDFStreamRef pdfSRef = myCGPDFStreamRef;
    ILPDFStream *pdfStream = [[ILPDFStream alloc] initWithStream:pdfSRef];
 
 ILPDFStream consists of the data representing the stream content and a NSDictionary representing the content info. ILPDFStream may also
 be instantiated based on a string representation of its contents without needing to be assoicated with
 a parent document.
 */


@class ILPDFDictionary;



@interface ILPDFStream : NSObject <ILPDFObject>

/**
 The Core Graphics stream reference, if it exists.
 */
@property (nonatomic, readonly) CGPDFStreamRef strm;

/** The data representing the stream content.
 @discussion It's important to reference dataFormat so that the data can be correctly interpreted.
 */
@property (nonatomic, readonly) NSData *data;

/** The data format for the stream content.
 */
@property (nonatomic, readonly) CGPDFDataFormat dataFormat;

/** The stream dictionary.
 */
@property (nonatomic, readonly) ILPDFDictionary *dictionary;


/**---------------------------------------------------------------------------------------
 * @name Creating a ILPDFStream
 *  ---------------------------------------------------------------------------------------
 */

/** Creates a new instance of ILPDFStream wrapping a CGPDFStreamRef
 
 @param pstrm A CGPDFStreamRef representing the PDF stream.
 @return A new ILPDFStream object.
 */
- (instancetype)initWithStream:(CGPDFStreamRef)pstrm NS_DESIGNATED_INITIALIZER;

/**---------------------------------------------------------------------------------------
 * @name Comparing Streams
 *  ---------------------------------------------------------------------------------------
 */

/** Returns a Boolean value that indicates whether the contents of the receiving stream are equal to the contents of another given stream.
 @param otherStream The stream with which to compare the receiving stream.
 @return YES if the contents of otherStream are equal to the contents of the receiving stream, otherwise NO.
 */
- (BOOL)isEqualToStream:(ILPDFStream *)otherStream;

@end

NS_ASSUME_NONNULL_END


