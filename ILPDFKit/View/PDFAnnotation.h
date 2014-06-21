//
//  PDFAnnotation.h
//  ILPDFKitSample
//
//  Created by Ved Prakash on 6/10/14.
//  Copyright (c) 2014 Iwe Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The identifier for FreeText annotations
 */
#define FREE_TEXT_ANNOTATION         @"FreeText"

@interface PDFAnnotation : NSObject
/**
 Defines the type of the annotation. In this version only FreeText is supported
 */
@property(nonatomic,retain) NSString * annotationType;

/**
 Defines the font of a FreeText annotation.
 */
@property(nonatomic,retain) UIFont * font;

/**
 The text of a FreeText annotation
 */
@property(nonatomic,retain) NSString * textString;

/**
 The view showing the annoatation.
 */
@property(nonatomic,retain) UIView * annotationView;

/**
 The text color of a FreeText annotation
 */
@property(nonatomic,retain) UIColor* textColor;

/**
 The alignment of a the text in a FreeText annotation
 */
@property UITextAlignment textAlignment;

/**
 The border Width of a Square or FreeText annotation. If the FreeText
 annotation is without border this value should be 0
 */
@property CGFloat borderWidth;

/**
 Initializes an PDFAnnotation with a specified PDF dictionary containing
 the annotation properties and a specified type
 @param annotDict The CGPDFDictionaryRef containing the annotation properties
 @param type The annotation type
 @return The newly initialized PDFAnnotation
 */
-(id)initWithPDFDictionary:(CGPDFDictionaryRef)annotDict andType:(NSString*)type;
@end
