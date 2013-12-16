
#import <QuartzCore/QuartzCore.h>
#import "PDFView.h"
#import "PDFUIAdditionElementView.h"
#import "PDFFormButtonField.h"
#import "PDF.h"



@interface PDFView()
@end


@implementation PDFView

-(void)dealloc
{
  
    [_pdfUIAdditionElementViews release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame DataOrPath:(id)dataOrPath AdditionViews:(NSArray*)uiAdditionViews
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGRect contentFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _pdfView = [[UIWebView alloc] initWithFrame:contentFrame];
        _pdfView.scalesPageToFit = YES;
        _pdfView.scrollView.delegate = self;
        _pdfView.scrollView.bouncesZoom = NO;
        _pdfView.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
         self.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        
       
        
       
        [self addSubview:_pdfView];
        [_pdfView release];
        [_pdfView.scrollView setZoomScale:1];
        [_pdfView.scrollView setContentOffset:CGPointZero];
        
        //This allows us to prevent the keyboard from obscuring text fields near the botton of the document.
        [_pdfView.scrollView setContentInset:UIEdgeInsetsMake(0, 0, frame.size.height/2, 0)];
        
        _pdfUIAdditionElementViews = [[NSMutableArray alloc] initWithArray:uiAdditionViews];
        
        for(PDFUIAdditionElementView* element in _pdfUIAdditionElementViews)
        {
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
        [tapGestureRecognizer release];
    }
    return self;
}


-(void)addPDFUIAdditionView:(PDFUIAdditionElementView*)viewToAdd
{
    [_pdfUIAdditionElementViews addObject:viewToAdd];
    [_pdfView.scrollView addSubview:viewToAdd];
}

-(void)removePDFUIAdditionView:(PDFUIAdditionElementView*)viewToRemove
{
    [viewToRemove removeFromSuperview];
    [_pdfUIAdditionElementViews removeObject:viewToRemove];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat scale = scrollView.zoomScale;
    if(scale < 1.0f)scale = 1.0f;
    
    for(PDFUIAdditionElementView* element in _pdfUIAdditionElementViews)
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
    if(_activeUIAdditionsView == nil)return NO;
    
    if(!CGRectContainsPoint(_activeUIAdditionsView.frame, [touch locationInView:_pdfView.scrollView]))
    {
        if([_activeUIAdditionsView isKindOfClass:[UITextView class]])
        {
            [_activeUIAdditionsView resignFirstResponder];
            
        }
        else
        {
            [_activeUIAdditionsView resign];
        }
    }
    return NO;
}


-(void)setUIAdditionViews:(NSArray*)additionViews
{
    
    for(UIView* v in _pdfUIAdditionElementViews)[v removeFromSuperview];
    [_pdfUIAdditionElementViews release];_pdfUIAdditionElementViews = nil;
    _pdfUIAdditionElementViews = [[NSMutableArray alloc] initWithArray:additionViews];
    for(PDFUIAdditionElementView* element in _pdfUIAdditionElementViews)
    {
        [_pdfView.scrollView addSubview:element];
        if([element isKindOfClass:[PDFFormButtonField class]])
        {
            [(PDFFormButtonField*)element setButtonSuperview];
        }
    }
}


@end




