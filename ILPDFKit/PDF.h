//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFDictionary.h"
#import "PDFArray.h"
#import "PDFStream.h"
#import "PDFForm.h"
#import "PDFPage.h"
#import "PDFDocument.h"
#import "PDFView.h"
#import "PDFViewController.h"


// Set this flag to ensure that the Core Graphics functions are used to parse the PDF file.
// Turning is flag off is experimental and not recommended.

#define PDFUseCGParsing 1

// Change the macros below to suit your own needs.

#define PDFDefaultCanvasWidth 612.0f
#define PDFDefaultCanvasHeight 792.0f
#define PDFDeviceToolbarHeight 20.0f
#define PDFDeviceNavBarHeight 44.0


#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define iPhone5 ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)&&[[UIScreen mainScreen] bounds].size.height == 568.0)
#define iPhone ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone))
#define iPhoneHardMinorWidth 320
#define iPhoneHardMajorWidth 480
#define iPhone5HardMajorWidth 568
#define iPadHardMinorWidth 768
#define iPadHardMajorWidth 1024



#define PDFDeviceMinorDimension (iPad?iPadHardMinorWidth:iPhoneHardMinorWidth)
#define PDFDeviceMajorDimension (iPad?iPadHardMajorWidth:(iPhone5?iPhone5HardMajorWidth:iPhoneHardMajorWidth))


// These numbers below are essentially the pixel margins between the edge of a UIWebView and the beginning of the PDF canvas to display

#define PDFLandscapePadWMargin 13.0f
#define PDFLandscapePadHMargin 7.25f


#define PDFPortraitPadWMargin 9.0f
#define PDFPortraitPadHMargin 6.10f


#define PDFPortraitPhoneWMargin 3.5
#define PDFPortraitPhoneHMargin 6.7


#define PDFLandscapePhoneWMargin 6.8
#define PDFLandscapePhoneHMargin 6.5


#define PDFWidgetColor [UIColor colorWithRed:0.7 green:0.85 blue:1.0 alpha:0.7]







