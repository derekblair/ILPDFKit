

#import "PDFFormButtonField.h"
#import "PDF.h"
#import <QuartzCore/QuartzCore.h>



@implementation PDFFormButtonField
@synthesize radio;
@synthesize noOff;
@synthesize pushButton;
@synthesize name;
@synthesize exportValue;

-(void)dealloc
{
    [val release];
    self.name = nil;
    self.exportValue = nil;
    [button removeFromSuperview];
    [button release];
    
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame Radio:(BOOL)rad
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        radio = rad;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        defFontSize = MIN(16, self.frame.size.height*0.75);
        button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        
        
        CGFloat minDim = MIN(frame.size.width,frame.size.height)*0.85;
        CGPoint center = CGPointMake(frame.size.width/2,frame.size.height/2);
        button.frame = CGRectMake(center.x-minDim, center.y-minDim, minDim*2, minDim*2);
        if(radio)button.layer.cornerRadius = button.frame.size.width/2;
        button.opaque = NO;
        button.backgroundColor = [UIColor clearColor];
        [self addSubview:button];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.userInteractionEnabled = NO;
        button.userInteractionEnabled  = YES;
    }
    return self;
}


-(void)setButtonSuperview
{
    [button removeFromSuperview];
    CGRect frame = self.bounds;
    CGFloat minDim = MIN(frame.size.width,frame.size.height)*0.85;
    CGPoint center = CGPointMake(frame.size.width/2,frame.size.height/2);
    button.frame = CGRectMake(center.x-minDim+self.frame.origin.x, center.y-minDim+self.frame.origin.y, 2*minDim,2*minDim);
    [self.superview insertSubview:button aboveSubview:self];
}


-(void)drawRect:(CGRect)rect
{
    if(pushButton)
    {
        [super drawRect:rect];
        return;
        
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    CGFloat minDim = MIN(rect.size.width,rect.size.height)*0.85;
    CGPoint center = CGPointMake(rect.size.width/2,rect.size.height/2);
    rect = CGRectMake(center.x-minDim/2, center.y-minDim/2, minDim, minDim);
    
    
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx,PDFWidgetColor.CGColor);
    if(radio == NO)
    {
        CGContextRef context = ctx;
        CGFloat radius = minDim/6;
        
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
        CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                        radius, M_PI, M_PI / 2, 1);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                                rect.origin.y + rect.size.height);
        CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                        rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
        CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                        radius, 0.0f, -M_PI / 2, 1);
        CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
        CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,
                        -M_PI / 2, M_PI, 1);
        
        CGContextFillPath(context);
    }
    else
    {
        CGContextFillEllipseInRect(ctx, rect);
    }
    
    CGContextRestoreGState(ctx);
    
    
    if(button.selected)
    {
        CGContextSaveGState(ctx);
        
        CGFloat margin = minDim/3;
        
        if(radio)
        {
            
            CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
            CGContextAddEllipseInRect(ctx, CGRectMake(margin, margin, rect.size.width-2*margin, rect.size.height-2*margin));
            CGContextFillPath(ctx);
            
        }
        else if(pushButton == NO)
        {
            CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
            CGContextSetLineWidth(ctx, rect.size.width/8);
            CGContextSetLineCap(ctx,kCGLineCapRound);
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextMoveToPoint(ctx, margin*0.75, rect.size.height/2);
            CGContextAddLineToPoint(ctx, rect.size.width/2-margin/4, rect.size.height-margin);
            CGContextAddLineToPoint(ctx, rect.size.width-margin*0.75, margin/2);
            
            CGContextStrokePath(ctx);
        }
        
        CGContextRestoreGState(ctx);
    }
}



-(void)setValue:(NSString*)value
{
    if([value isKindOfClass:[NSNull class]]==YES)
    {
        self.value = nil;
        return;
    }
    if(val!=value)
    {
        [val release];val = [value retain];
    }
    if(val)
    {
        button.selected = [val isEqualToString:exportValue];
    }
    else
    {
        button.selected = NO;
    }
    [self refresh];
}

-(NSString*)value
{
    return val;
}


-(void)updateWithZoom:(CGFloat)zoom
{
    [super updateWithZoom:zoom];
    
    
    
    CGFloat minDim = MIN(self.bounds.size.width,self.bounds.size.height)*0.85;
    CGPoint center = CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2);
    button.frame = CGRectMake(center.x-minDim+self.frame.origin.x, center.y-minDim+self.frame.origin.y, minDim*2, minDim*2);
    if(radio)
    button.layer.cornerRadius = button.frame.size.width/2;
    [self refresh];
    [button setNeedsDisplay];
}



-(void)buttonPressed:(id)sender
{
    [delegate uiAdditionValueChanged:self];
}


-(void)vectorRenderInPDFContext:(CGContextRef)ctx ForRect:(CGRect)rect
{
    
    
    CGFloat minDim = MIN(rect.size.width,rect.size.height)*0.85;
    CGPoint center = CGPointMake(rect.size.width/2,rect.size.height/2);
    rect = CGRectMake(center.x-minDim/2, center.y-minDim/2, minDim, minDim);
    
    if(button.selected)
    {
        CGContextSaveGState(ctx);
        
        CGFloat margin = minDim/3;
        
        if(radio)
        {
            
            CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
            CGContextAddEllipseInRect(ctx, CGRectMake(margin, margin, rect.size.width-2*margin, rect.size.height-2*margin));
            CGContextFillPath(ctx);
            
        }
        else if(pushButton == NO)
        {
            CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
            CGContextSetLineWidth(ctx, rect.size.width/8);
            CGContextSetLineCap(ctx,kCGLineCapRound);
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextMoveToPoint(ctx, margin*0.75, rect.size.height/2);
            CGContextAddLineToPoint(ctx, rect.size.width/2-margin/4, rect.size.height-margin);
            CGContextAddLineToPoint(ctx, rect.size.width-margin*0.75, margin/2);
            CGContextStrokePath(ctx);
        }
        
        CGContextRestoreGState(ctx);
    }
}

#pragma mark - setter


-(void)setPushButton:(BOOL)pb
{
    pushButton = pb;
    
    if(pushButton)
    {
     
        self.backgroundColor = [UIColor whiteColor];
    }
    
}


-(void)setNoOff:(BOOL)no
{
    noOff = no;
}

-(void)setRadio:(BOOL)rd
{
    radio = rd;
}


@end
