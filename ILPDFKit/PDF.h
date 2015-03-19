// PDF.h
//
// Copyright (c) 2015 Iwe Labs
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

#define PDFUseCGParsing YES

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







