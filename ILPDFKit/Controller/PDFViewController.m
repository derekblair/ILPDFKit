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

#import <ILPDFKit/ILPDFKit.h>
#import "PDFFormContainer.h"

@interface PDFViewController(Private)
- (void)loadPDFView;
@end


@implementation PDFViewController {
    PDFView *_pdfView;
}

#pragma mark - UIViewController 


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.pdfName && _document == nil) {
        PDFDocument *doc = [[PDFDocument alloc] initWithResource:self.pdfName];
        [self setDocument:doc];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _pdfView.frame = CGRectMake(0,self.topLayoutGuide.length,self.view.bounds.size.width,self.view.bounds.size.height-self.topLayoutGuide.length);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self loadPDFView];
}

#pragma mark - PDFViewController

- (void)setDocument:(PDFDocument *)document {
    _document = document;
    [self loadPDFView];
}

- (void)reload {
    [_document refresh];
    [self loadPDFView];
}

#pragma mark - Private

- (void)loadPDFView {
    for (PDFForm *form in self.document.forms) {
        [form removeObservers];
    }
    [_pdfView removeFromSuperview];
    _pdfView = nil;
    
    if (self.document) {
        _pdfView = [[PDFView alloc] initWithFrame:CGRectZero];
        [_pdfView setupWithDocument:self.document];
        [self.view addSubview:_pdfView];
    }
    [self.view setNeedsLayout];
}



@end
