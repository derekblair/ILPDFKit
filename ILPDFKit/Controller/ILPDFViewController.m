// ILPDFViewController.m
//
// Copyright (c) 2017 Derek Blair
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
#import <ILPDFKit/ILPDFKit-Swift.h>

@interface ILPDFViewController(Private)
- (void)loadPDFView;
@property (nonatomic, strong) ILPDFView *pdfView;
@end


@implementation ILPDFViewController
#pragma mark - UIViewController

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self loadPDFView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
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

// Override to customize constraints.
- (void)applyConstraintsToPDFView {
    [_pdfView pinToSuperview:UIEdgeInsetsZero guide:self.view.layoutMarginsGuide];
}

#pragma mark - Private

- (void)loadPDFView {
    if (_pdfView.superview != nil) {
        [_pdfView removeFromSuperview];
    }
    _pdfView = [[ILPDFView alloc] initWithDocument:_document];
    [self.view addSubview:_pdfView];
    [self applyConstraintsToPDFView];
}



@end
