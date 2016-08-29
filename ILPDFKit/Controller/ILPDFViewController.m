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
#import "ILPDFSignatureController.h"
#import "ILPDFFormSignatureField.h"

@interface ILPDFViewController(Private) <ILPDFSignatureControllerDelegate>
- (void)loadPDFView;
@end


@implementation ILPDFViewController {
    ILPDFView *_pdfView;
    ILPDFSignatureController *signatureController;
    ILPDFFormSignatureField *signatureField;
}

#pragma mark - UIViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];

}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSignatureViewController:)
                                                 name:@"SignatureNotification"
                                               object:nil];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Alter or remove to define your own layout logic for the ILPDFView.
    _pdfView.frame = CGRectMake(0,self.topLayoutGuide.length,self.view.bounds.size.width,self.view.bounds.size.height-self.topLayoutGuide.length - self.bottomLayoutGuide.length);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self loadPDFView];
}

- (void) viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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

#pragma mark - KVO

- (void) showSignatureViewController:(NSNotification *) notification {
    
    if ([notification.object isKindOfClass:[ILPDFFormSignatureField class]]) {
        signatureField = notification.object;
    }
    signatureController = [[ILPDFSignatureController alloc] initWithNibName:@"ILPDFSignatureController" bundle:nil];
    signatureController.expectedSignSize = signatureField.frame.size;
    signatureController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    signatureController.delegate = self;
    [self presentViewController:signatureController animated:YES completion:nil];
    
}

#pragma mark - Signature Controller Delegate

- (void) signedWithImage:(UIImage*) signatureImage {
    
    [signatureField removeButtonTitle];
    signatureField.signatureImage.image = signatureImage;
    [signatureField informDelegateAboutNewImage];
    signatureField = nil;
    
}



@end
