// ILPDFViewController.m
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

#import <ILPDFKit/ILPDFKit.h>
#import "ILPDFFormContainer.h"

@interface ILPDFViewController(Private)
- (void)loadPDFView;
@end


@implementation ILPDFViewController {
    ILPDFView *_pdfView;
}

#pragma mark - UIViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Alter or remove to define your own layout logic for the ILPDFView.
    _pdfView.frame = CGRectMake(0,self.topLayoutGuide.length,self.view.bounds.size.width,self.view.bounds.size.height-self.topLayoutGuide.length - self.bottomLayoutGuide.length);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self loadPDFView];
}

#pragma mark - ILPDFViewController

#pragma mark - Setting the Document
- (void)setDocument:(ILPDFDocument *)document {
    _document = document;
    [self loadPDFView];
}

#pragma mark - Relaoding the Document
- (void)reload {
    [_document refresh];
    [self loadPDFView];
}

#pragma mark - Private

- (void)loadPDFView {
    [_pdfView removeFromSuperview];
    _pdfView = [[ILPDFView alloc] initWithDocument:_document];
    [self.view addSubview:_pdfView];
}



@end
