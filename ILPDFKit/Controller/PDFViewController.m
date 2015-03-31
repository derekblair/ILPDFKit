// PDFViewController.m
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

#import "PDF.h"
#import "PDFFormContainer.h"

@interface PDFViewController(Private)
- (void)loadPDFView;
- (CGRect)currentFrame:(UIInterfaceOrientation)o;
@property (nonatomic, getter=getMargins, readonly) CGPoint margins;
@end

@implementation PDFViewController

#pragma mark - NSObject

- (void)dealloc {
    [self removeFromParentViewController];
    [_pdfView removeFromSuperview];
    self.pdfView = nil;
    self.document = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.opaque = YES;
    [self loadPDFView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _pdfView.alpha = 0;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    for (PDFForm *form in self.document.forms) {
        [form removeObservers];
    }
    [_pdfView removeFromSuperview];self.pdfView = nil;
    [self loadPDFView];
}

#pragma mark - PDFViewController

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self != nil) {
        _document = [[PDFDocument alloc] initWithData:data];
    }
    return self;
}

- (instancetype)initWithResource:(NSString *)name {
    self = [super init];
    if (self != nil) {
        _document = [[PDFDocument alloc] initWithResource:name];
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if(self != nil) {
        _document = [[PDFDocument alloc] initWithPath:path];
    }
    return self;
}

- (void)reload {
    [_document refresh];
    [_pdfView removeFromSuperview];
    _pdfView = nil;
    [self loadPDFView];
}

#pragma mark - Private

- (CGRect)currentFrame:(UIInterfaceOrientation)o {
    if(UIInterfaceOrientationIsPortrait(o)) {
        return CGRectMake(0, 0, PDFDeviceMinorDimension, PDFDeviceMajorDimension);
    } else {
        return CGRectMake(0, 0, PDFDeviceMajorDimension, PDFDeviceMinorDimension);
    }
}

- (void)loadPDFView {
    id pass = (_document.documentPath ? _document.documentPath:_document.documentData);
    CGRect frm = [self currentFrame:self.interfaceOrientation];
    self.view.frame = CGRectMake(0,self.view.frame.origin.y,frm.size.width,frm.size.height-self.view.frame.origin.y);
    CGPoint margins = [self getMargins];
    NSArray *additionViews = [_document.forms createWidgetAnnotationViewsForSuperviewWithWidth:frm.size.width margin:margins.x hMargin:margins.y];
    _pdfView = [[PDFView alloc] initWithFrame:self.view.bounds dataOrPath:pass additionViews:additionViews];
    [self.view addSubview:_pdfView];
}

- (CGPoint)getMargins {
    if(iPad) {
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))return CGPointMake(PDFPortraitPadWMargin,PDFPortraitPadHMargin);
        else return CGPointMake(PDFLandscapePadWMargin,PDFLandscapePadHMargin);
    } else {
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))return CGPointMake(PDFPortraitPhoneWMargin,PDFPortraitPhoneHMargin);
        else return CGPointMake(PDFLandscapePhoneWMargin,PDFLandscapePhoneHMargin);
    }
}

@end
