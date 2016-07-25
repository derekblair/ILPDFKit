// ILPDFView.m
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

#import <QuartzCore/QuartzCore.h>
#import "ILPDFFormButtonField.h"
#import "ILPDFFormContainer.h"
#import <ILPDFKit/ILPDFKit.h>

@interface ILPDFView(Delegates) <UIScrollViewDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate>
@end

@interface ILPDFView(Private)
- (void)fadeInWidgetAnnotations;
@end

@implementation ILPDFView {
    BOOL _canvasLoaded;
    __weak ILPDFDocument *_pdfDocument;
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIView *_uiWebPDFView;
    NSMapTable *_pdfPages;
    NSMutableArray *_pageYValues;
    BOOL _layoutHasOccured;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [_pdfView setFrame:self.bounds];
    [_pdfView.scrollView setContentInset:UIEdgeInsetsMake(0, 0, self.bounds.size.height/2, 0)];

    if (!CGRectEqualToRect(self.bounds, CGRectZero) && self.window && !_layoutHasOccured) {
        _layoutHasOccured = YES;


        _pdfView = [[UIWebView alloc] initWithFrame:self.bounds];
        [_pdfView.scrollView setContentInset:UIEdgeInsetsMake(0, 0, self.bounds.size.height/2, 0)];
        _pdfView.scalesPageToFit = YES;
        _pdfView.scrollView.delegate = self;
        _pdfView.scrollView.bouncesZoom = NO;
        _pdfView.delegate = self;
        [self addSubview:_pdfView];
        [_pdfView.scrollView setZoomScale:1];



        if ([_pdfDocument.documentPath isKindOfClass:[NSString class]]) {
            [_pdfView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_pdfDocument.documentPath]]];
        } else  {
            [_pdfView loadData:_pdfDocument.documentData MIMEType:@"application/pdf" textEncodingName:@"NSASCIIStringEncoding" baseURL:[NSURL URLWithString:@"/"]];
        }
    }

    if (_canvasLoaded) {
        [self updatePDFPageViews];
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
    for (UIView *sv in _uiWebPDFView.subviews) {
        if ([NSStringFromClass(sv.class) isEqualToString:@"UIPDFPageView"]) {
            if ([[[_pdfPages objectEnumerator] allObjects] containsObject:sv]) continue;
            NSUInteger yVal = (NSUInteger)floor(sv.frame.origin.y);
            if (![_pageYValues containsObject:@(yVal)]) {
                [_pageYValues addObject:@(yVal)];
            }
            [_pageYValues sortUsingSelector:@selector(compare:)];
            [_pdfPages setObject:sv forKey:@([_pageYValues indexOfObject:@(yVal)]+1)];
        }
    }
    [_pdfDocument.forms updateWidgetAnnotationViews:_pdfPages views:_pdfWidgetAnnotationViews pdfView:self];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _canvasLoaded = YES;
    for (UIView *sv in webView.scrollView.subviews) {
        if ([NSStringFromClass(sv.class) isEqualToString:@"UIWebPDFView"]) {
            _uiWebPDFView = sv;
            break;
        }
    }

    [self updatePDFPageViews];
    for (ILPDFWidgetAnnotationView *element in _pdfWidgetAnnotationViews) {
        element.alpha = 0;
    }
    if (_pdfWidgetAnnotationViews) {
        [self fadeInWidgetAnnotations];
    }
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
    static NSUInteger times = 0;
    times++;
    if (times % 4 == 0) {
        [self updatePDFPageViews];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_activeWidgetAnnotationView == nil) return NO;
    if (!CGRectContainsPoint(_activeWidgetAnnotationView.frame, [touch locationInView:_pdfView.scrollView])) {
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
        for (UIView *v in _pdfWidgetAnnotationViews) v.alpha = 1;
    } completion:^(BOOL finished) {}];
}


@end




