// ILPDFFormSignatureField.m
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

#import "ILPDFFormSignatureField.h"

@implementation ILPDFFormSignatureField

#pragma mark - UIView

// This class is incomplete. Signature fields are not implemented currently. We mark them red.
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 1.0;
        [self addSignatureImageViewWithFrame:frame];
        [self addButtonWithFrame:frame];
    }
    return self;
}


#pragma mark - UIImage

- (void) addSignatureImageViewWithFrame:(CGRect) frame {
    CGRect signatureFrame = frame;
    signatureFrame.origin = CGPointMake(0, 0);
    self.signatureImage = [[UIImageView alloc] initWithFrame:signatureFrame];
    self.signatureImage.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.signatureImage];
    
}

#pragma mark - Button

- (void) addButtonWithFrame:(CGRect) frame {
    
    CGRect buttonFrame = frame;
    buttonFrame.origin = CGPointMake(0, 0);
    
    self.signatureButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [self.signatureButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.signatureButton setTitle:@"Tap to Sign" forState:UIControlStateNormal];
    [self.signatureButton addTarget:self action:@selector(openSignatureView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.signatureButton];
    
}

- (void) removeButtonTitle {
    [self.signatureButton setTitle:@"" forState:UIControlStateNormal];
}

#pragma mark - Signature View

- (void) openSignatureView {
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"SignatureNotification" object:self userInfo:nil];
    
}

#pragma mark - Rendering

+ (void)drawWithRect:(CGRect)frame context:(CGContextRef)ctx withImage:(UIImage*) image {
    //draw image in the context
    CGContextTranslateCTM(ctx, 0, frame.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextDrawImage(ctx, CGRectMake(0, 0, frame.size.width,frame.size.height), (image).CGImage);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextTranslateCTM(ctx, 0, -frame.size.height);

    }
#pragma mark - DelegateInform
- (void) informDelegateAboutNewImage {
    [self.delegate widgetAnnotationValueChanged:self];

}
@end
