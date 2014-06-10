//
//  PDFAnnotation.m
//  ILPDFKitSample
//
//  Created by Ved Prakash on 6/10/14.
//  Copyright (c) 2014 Iwe Labs. All rights reserved.
//

#import "PDFAnnotation.h"

@implementation PDFAnnotation
@synthesize annotationType,font,textString;
@synthesize textColor;
@synthesize textAlignment;
@synthesize borderWidth;


-(id)initWithPDFDictionary:(CGPDFDictionaryRef)annotDict andType:(NSString *)type{
    self=[super init];
    self.annotationType = type;
    
    if ([type isEqualToString:FREE_TEXT_ANNOTATION]){
        
        CGPDFStringRef fontTypeRef;
        if(CGPDFDictionaryGetString(annotDict, "DA", &fontTypeRef)) {
            NSString* fontType = (__bridge NSString *)CGPDFStringCopyTextString(fontTypeRef);
            NSArray *firstWords = [fontType componentsSeparatedByString:@" "];
            NSString *tempStr = [firstWords objectAtIndex:0];
            fontType = [tempStr substringFromIndex:1];
            
            tempStr=[firstWords objectAtIndex:1];
            NSInteger fontSize = [tempStr intValue];
            if ([firstWords count]>5) {
                CGFloat red = [[firstWords objectAtIndex:3] floatValue];
                CGFloat green = [[firstWords objectAtIndex:4] floatValue];
                CGFloat blue = [[firstWords objectAtIndex:5] floatValue];
                self.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
            }
            else{
                self.textColor = [UIColor blackColor];
            }
            self.font = [UIFont fontWithName:fontType size:fontSize];
        }
        else{
            textColor=[UIColor blackColor];
            self.font = [UIFont fontWithName:@"Helvetica" size:12];
        }
        CGPDFInteger textAlignmentRef;
        if (CGPDFDictionaryGetInteger(annotDict, "Q", &textAlignmentRef)) {
            switch (textAlignmentRef) {
                case 1:
                    self.textAlignment = UITextAlignmentCenter;
                    break;
                case 2:
                    self.textAlignment = UITextAlignmentRight;
                    break;
                    
                default:
                    self.textAlignment = UITextAlignmentLeft;
                    break;
            }
        }
        else self.textAlignment = UITextAlignmentLeft;
        
        CGPDFStringRef textStringRef;
        if(CGPDFDictionaryGetString(annotDict, "Contents", &textStringRef)) {
            self.textString = (__bridge NSString *)CGPDFStringCopyTextString(textStringRef);
        }
        
    }
    CGPDFArrayRef borderArray;
    if (CGPDFDictionaryGetArray(annotDict, "Border",&borderArray)){
        int cArrayCount = CGPDFArrayGetCount( borderArray );
        for( int k = 0; k < cArrayCount; ++k ) {
            CGPDFObjectRef borderObj;
            if(!CGPDFArrayGetObject(borderArray, k, &borderObj)) {
                break;
            }
            CGPDFReal border;
            if(!CGPDFObjectGetValue(borderObj, kCGPDFObjectTypeReal, &border)) {
                break;
            }
            
            if (k==2) {
                self.borderWidth = border;
            }
        }
    }
    else{
        self.borderWidth = 1;
    }
    
    CGPDFDictionaryRef borderStyleDict;
    if (CGPDFDictionaryGetDictionary(annotDict, "BS",&borderStyleDict)){
        CGPDFReal borderStyleWidth;
        if(CGPDFDictionaryGetNumber(borderStyleDict, "W", &borderStyleWidth)){
            self.borderWidth = borderStyleWidth;
        }
    }
    
    return self;
}
@end
