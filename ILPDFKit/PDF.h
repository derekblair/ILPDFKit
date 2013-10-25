
#import "PDFDictionary.h"
#import "PDFArray.h"
#import "PDFStream.h"
#import "PDFForm.h"
#import "PDFPage.h"
#import "PDFDocument.h"
#import "PDFView.h"
#import "PDFViewController.h"

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

#define PDFLandscapePadWMargin 13.0
#define PDFLandscapePadHMargin 7.0
#define PDFPortraitPadWMargin 9.0
#define PDFPortraitPadHMargin 7.0
#define PDFPortraitPhoneWMargin 3.0
#define PDFPortraitPhoneHMargin 7.0
#define PDFLandscapePhoneWMargin 6.0
#define PDFLandscapePhoneHMargin 7.0


#define PDFWidgetColor [UIColor colorWithRed:0.7 green:0.85 blue:1.0 alpha:0.7]