
#import <QuartzCore/QuartzCore.h>
#import "PDFView.h"
#import "PDFUIAdditionElementView.h"
#import "PDFFormButtonField.h"




@interface PDFView()



    

@end


@implementation PDFView


@synthesize activeUIAdditionsView;
@synthesize pdfUIAdditionElementViews;
@synthesize pdfView;


-(void)dealloc
{
  
    [pdfUIAdditionElementViews release];
   
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame DataOrPath:(id)dataOrPath AdditionViews:(NSArray*)uiAdditionViews
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGRect contentFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        pdfView = [[UIWebView alloc] initWithFrame:contentFrame];
        pdfView.scalesPageToFit = YES;
        pdfView.scrollView.delegate = self;
        pdfView.scrollView.bouncesZoom = NO;
        pdfView.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
        pdfView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, frame.size.height/2, 0);
       
        [self addSubview:pdfView];
        [pdfView release];
        
        
       
        
        pdfUIAdditionElementViews = [[NSMutableArray alloc] initWithArray:uiAdditionViews];
        for(PDFUIAdditionElementView* element in pdfUIAdditionElementViews)
        {
            [pdfView.scrollView addSubview:element];
            if([element isKindOfClass:[PDFFormButtonField class]])
            {
                [(PDFFormButtonField*)element setButtonSuperview];
            }
        }
        
        if([dataOrPath isKindOfClass:[NSString class]])
        {
            [pdfView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:dataOrPath]]];
        }
        else if([dataOrPath isKindOfClass:[NSData class]])
        {
            [pdfView loadData:dataOrPath MIMEType:@"application/pdf" textEncodingName:@"NSASCIIStringEncoding" baseURL:nil];
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
    [pdfUIAdditionElementViews addObject:viewToAdd];
    [pdfView.scrollView addSubview:viewToAdd];
}

-(void)removePDFUIAdditionView:(PDFUIAdditionElementView*)viewToRemove
{
    [viewToRemove removeFromSuperview];
    [pdfUIAdditionElementViews removeObject:viewToRemove];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat scale = scrollView.zoomScale;
    if(scale < 1.0f)scale = 1.0f;
    
    for(PDFUIAdditionElementView* element in pdfUIAdditionElementViews)
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
    if(activeUIAdditionsView == nil)return NO;
    
    if(!CGRectContainsPoint(activeUIAdditionsView.frame, [touch locationInView:pdfView.scrollView]))
    {
        if([activeUIAdditionsView isKindOfClass:[UITextView class]])
        {
            [activeUIAdditionsView resignFirstResponder];
            
        }
        else
        {
            [activeUIAdditionsView resign];
        }
    }
    return NO;
}


-(void)setUIAdditionViews:(NSArray*)additionViews
{
    
    for(UIView* v in pdfUIAdditionElementViews)[v removeFromSuperview];
    [pdfUIAdditionElementViews release];pdfUIAdditionElementViews = nil;
    pdfUIAdditionElementViews = [[NSMutableArray alloc] initWithArray:additionViews];
    for(PDFUIAdditionElementView* element in pdfUIAdditionElementViews)
    {
        [pdfView.scrollView addSubview:element];
        if([element isKindOfClass:[PDFFormButtonField class]])
        {
            [(PDFFormButtonField*)element setButtonSuperview];
        }
    }
}






@end




