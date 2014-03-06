//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "PDFView.h"
#import "PDFWidgetAnnotationView.h"
#import "PDFFormButtonField.h"
#import "PDF.h"



@interface PDFView()
    -(void)fadeInWidgetAnnotations;
@end


@implementation PDFView
{
    BOOL _canvasLoaded;
}

- (id)initWithFrame:(CGRect)frame DataOrPath:(id)dataOrPath AdditionViews:(NSArray*)widgetAnnotationViews
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGRect contentFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _pdfView = [[UIWebView alloc] initWithFrame:contentFrame];
        _pdfView.scalesPageToFit = YES;
        _pdfView.scrollView.delegate = self;
        _pdfView.scrollView.bouncesZoom = NO;
        _pdfView.delegate = self;
        _pdfView.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
         self.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        
        [self addSubview:_pdfView];
        [_pdfView.scrollView setZoomScale:1];
        [_pdfView.scrollView setContentOffset:CGPointZero];
        
        //This allows us to prevent the keyboard from obscuring text fields near the botton of the document.
        [_pdfView.scrollView setContentInset:UIEdgeInsetsMake(0, 0, frame.size.height/2, 0)];
        
        _pdfWidgetAnnotationViews = [[NSMutableArray alloc] initWithArray:widgetAnnotationViews];
        
        for(PDFWidgetAnnotationView* element in _pdfWidgetAnnotationViews)
        {
            element.alpha = 0;
            element.parentView = self;
            [_pdfView.scrollView addSubview:element];
            
            if([element isKindOfClass:[PDFFormButtonField class]])
            {
                [(PDFFormButtonField*)element setButtonSuperview];
            }
        }
        
        if([dataOrPath isKindOfClass:[NSString class]])
        {
            [_pdfView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:dataOrPath]]];
        }
        else if([dataOrPath isKindOfClass:[NSData class]])
        {
            [_pdfView loadData:dataOrPath MIMEType:@"application/pdf" textEncodingName:@"NSASCIIStringEncoding" baseURL:nil];
        }

        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
            [self addGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer.delegate = self;
    }
    return self;
}


-(void)addPDFWidgetAnnotationView:(PDFWidgetAnnotationView*)viewToAdd
{
    [_pdfWidgetAnnotationViews addObject:viewToAdd];
    [_pdfView.scrollView addSubview:viewToAdd];
}

-(void)removePDFWidgetAnnotationView:(PDFWidgetAnnotationView*)viewToRemove
{
    [viewToRemove removeFromSuperview];
    [_pdfWidgetAnnotationViews removeObject:viewToRemove];
}


#pragma mark - UIWebViewDelegate


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    _canvasLoaded = YES;
    if(_pdfWidgetAnnotationViews)
    {
        [self fadeInWidgetAnnotations];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat scale = scrollView.zoomScale;
    if(scale < 1.0f)scale = 1.0f;
    
    for(PDFWidgetAnnotationView* element in _pdfWidgetAnnotationViews)
    {
        [element updateWithZoom:scale];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   
}

#pragma mark - UIGestureRecognizerDelegate


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(_activeWidgetAnnotationView == nil)return NO;
    
    if(!CGRectContainsPoint(_activeWidgetAnnotationView.frame, [touch locationInView:_pdfView.scrollView]))
    {
        if([_activeWidgetAnnotationView isKindOfClass:[UITextView class]])
        {
            [_activeWidgetAnnotationView resignFirstResponder];
            
        }
        else
        {
            [_activeWidgetAnnotationView resign];
        }
    }
    return NO;
}


-(void)setWidgetAnnotationViews:(NSArray*)additionViews
{
    
    for(UIView* v in _pdfWidgetAnnotationViews)[v removeFromSuperview];
    _pdfWidgetAnnotationViews = nil;
    _pdfWidgetAnnotationViews = [[NSMutableArray alloc] initWithArray:additionViews];
    
    for(PDFWidgetAnnotationView* element in _pdfWidgetAnnotationViews)
    {
        element.alpha = 0;
        element.parentView = self;
        [_pdfView.scrollView addSubview:element];
        if([element isKindOfClass:[PDFFormButtonField class]])
        {
            [(PDFFormButtonField*)element setButtonSuperview];
        }
    }
    
    
    if(_canvasLoaded)[self fadeInWidgetAnnotations];
}


#pragma mark - Hidden


-(void)fadeInWidgetAnnotations
{
    [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
        for(UIView* v in _pdfWidgetAnnotationViews)v.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}


@end




