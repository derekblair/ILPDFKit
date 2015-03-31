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
#import "PDFString.h"
#import "PDFName.h"
#import "PDFNumber.h"
#import "PDFNull.h"

#import "PDFForm.h"
#import "PDFPage.h"
#import "PDFDocument.h"
#import "PDFView.h"
#import "PDFWidgetAnnotationView.h"
#import "PDFViewController.h"
#import "PDFUtility.h"


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

#define PDFFormMinFontSize 8
#define PDFFormMaxFontSize 22

#define isWS(c) ((c) == 0 || (c) == 9 || (c) == 10 || (c) == 12 || (c) == 13 || (c) == 32)
#define isDelim(c) ((c) == '(' || (c) == ')' || (c) == '<' || (c) == '>' || (c) == '[' || (c) == ']' || (c) == '{' || (c) == '}' || (c) == '/' ||  (c) == '%')
#define isODelim(c) ((c) == '(' ||  (c) == '<' ||  (c) == '[')
#define isCDelim(c) ((c) == ')' ||  (c) == '>' ||  (c) == ']')

#define PDFButtonMinScaledDimensionScaleFactor 0.85
#define PDFChoiceFieldBaseFontSizeToFrameHeightScaleFactor 0.8
#define PDFButtonMinScaledDimension(r) MIN((r).size.width,(r).size.height)*PDFButtonMinScaledDimensionScaleFactor
#define PDFButtonMarginScaleFactor 0.75
//The scale of the font size with respect to the field height.
#define PDFTextFieldFontScaleFactor 0.75
#define PDFChoiceFieldRowHeightDivisor MIN(5,[self.options count])
// PDF uses ASCII for readable characters, but allows any 8 bit value unlike ASCII, so we use an extended ASCII set here.
// The character mapped to encoded bytes over 127 have no significance, and are octal escaped if needed to be read as text in the PDF file itself.
#define PDFStringCharacterEncoding NSISOLatin1StringEncoding

