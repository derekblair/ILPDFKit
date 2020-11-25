// ILPDFView.m
//
// Copyright (c) 2018 Derek Blair
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

#import <QuartzCore/QuartzCore.h>
#import <PDFKit/PDFKit.h>

#import "ILPDFFormButtonField.h"
#import "ILPDFFormContainer.h"
#import "ILPDFView.h"
#import "ILPDFDictionary.h"
#import "ILPDFString.h"
#import "ILPDFArray.h"
#import "ILPDFDocument.h"


static NSString *const ILPDFMIMEType = @"application/pdf";
static NSString *const ILPDFCharEncoding = @"NSASCIIStringEncoding";


@interface ILPDFView(Delegates) <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@end

@interface ILPDFView(Private)
- (void)fadeInWidgetAnnotations;
@end

@implementation ILPDFView {
    __weak ILPDFDocument *_pdfDocument;
    UITapGestureRecognizer *_tapGestureRecognizer;
    NSMapTable *_pdfPages;
    NSMutableArray *_pageYValues;
    PDFView *_pdfView;
    UIView *_pdfDocumentView;
    UIScrollView *_scrollView;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updatePDFPageViews];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window != NULL) {
        for (UIView *sv in _pdfView.subviews) {
            if ([sv isKindOfClass: UIScrollView.class]) {
                _scrollView = ((UIScrollView *)sv);
                _scrollView.delegate = self;
                for (UIView *s in sv.subviews) {
                    if ([NSStringFromClass(s.class) isEqualToString:@"PDFDocumentView"]) {
                        _pdfDocumentView = s;
                    }
                }
                break;
            }
        }
    }
}



#pragma mark - ILPDFView

- (instancetype)initWithDocument:(ILPDFDocument *)document {
    self = [super initWithFrame:CGRectZero];
    if (self != nil) {
        for (ILPDFForm *form in document.forms) {
            [form removeObservers];
        }
        _pageYValues = [NSMutableArray array];
        _pdfPages = [NSMapTable strongToWeakObjectsMapTable];
        _pdfWidgetAnnotationViews = [NSMutableArray array];
        _pdfDocument = document;
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
        [self addGestureRecognizer:_tapGestureRecognizer];
        _tapGestureRecognizer.delegate = self;
        [self addSubview:self.pdfView];
        [self.pdfView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [self init];
     NSAssert(NO,@"Non-Supported Initializer");
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    NSAssert(NO,@"Non-Supported Initializer");
    return nil;
}


#pragma mark - PDF Page Views


- (void)updatePDFPageViews {
    
    if (_pdfDocumentView == nil) {
        return;
    }
    BOOL pagesHaveChanged = NO;

    for (UIView *sv in [_pdfDocumentView valueForKeyPath:@"pageViews"] ) {
        if ([NSStringFromClass(sv.class) isEqualToString:@"PDFPageView"]) {
            if ([[[_pdfPages objectEnumerator] allObjects] containsObject:sv]) continue;
            pagesHaveChanged = YES;
            NSUInteger yVal = (NSUInteger)floor(sv.frame.origin.y);
            if (![_pageYValues containsObject:@(yVal)]) {
                [_pageYValues addObject:@(yVal)];
            }
            [_pageYValues sortUsingSelector:@selector(compare:)];
            NSUInteger page = MAX((NSUInteger)floor(sv.frame.origin.y/sv.frame.size.height) + 1,[_pageYValues indexOfObject:@(yVal)]+1);
            [_pdfPages setObject:sv forKey:@(page)];
        }
    }
    if (pagesHaveChanged) {
        [_pdfDocument.forms updateWidgetAnnotationViews:_pdfPages views:_pdfWidgetAnnotationViews pdfView:self];
    }
}


#pragma mark - Loading the PDFView

- (PDFView *)pdfView {
    if (_pdfView == nil) {
        _pdfView = [[PDFView alloc] init];
        _pdfView.document = [_pdfDocument nativeDocument];
    }
    return _pdfView;
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat scale = scrollView.zoomScale;
    if (scale < 1.0f) scale = 1.0f;
    for (ILPDFWidgetAnnotationView *element in _pdfWidgetAnnotationViews) {
        [element updateWithZoom:scale];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updatePDFPageViews];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_activeWidgetAnnotationView == nil) return NO;
    if (!CGRectContainsPoint(_activeWidgetAnnotationView.frame, [touch locationInView: _scrollView])) {
        if ([_activeWidgetAnnotationView isKindOfClass:[UITextView class]]) {
            [_activeWidgetAnnotationView resignFirstResponder];
        } else {
            [_activeWidgetAnnotationView resign];
        }
    }
    return NO;
}

#pragma mark - Private

- (void)fadeInWidgetAnnotations {
    [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
        for (UIView *v in self->_pdfWidgetAnnotationViews) v.alpha = 1;
    } completion:^(BOOL finished) {}];
}


@end




