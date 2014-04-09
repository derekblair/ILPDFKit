//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFFormButtonField.h"
#import "PDF.h"
#import <QuartzCore/QuartzCore.h>



@implementation PDFFormButtonField
{
    NSString* _val;
    NSUInteger _defFontSize;
    UIButton* _button;
}


-(void)dealloc
{
    _val = nil;
    self.name = nil;
    self.exportValue = nil;
    [_button removeFromSuperview];
    _button = nil;
}

-(id)initWithFrame:(CGRect)frame Radio:(BOOL)rad
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        _radio = rad;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        _defFontSize = MIN(16, self.frame.size.height*0.75);
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat minDim = MIN(frame.size.width,frame.size.height)*0.85;
        CGPoint center = CGPointMake(frame.size.width/2,frame.size.height/2);
        _button.frame = CGRectMake(center.x-minDim, center.y-minDim, minDim*2, minDim*2);
        if(_radio)_button.layer.cornerRadius = _button.frame.size.width/2;
        _button.opaque = NO;
        _button.backgroundColor = [UIColor clearColor];
        [self addSubview:_button];
        [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.userInteractionEnabled = NO;
        _button.userInteractionEnabled  = YES;
    }
    return self;
}


-(void)setButtonSuperview
{
    [_button removeFromSuperview];
    CGRect frame = self.bounds;
    CGFloat minDim = MIN(frame.size.width,frame.size.height)*0.85;
    CGPoint center = CGPointMake(frame.size.width/2,frame.size.height/2);
    _button.frame = CGRectMake(center.x-minDim+self.frame.origin.x, center.y-minDim+self.frame.origin.y, 2*minDim,2*minDim);
    [self.superview insertSubview:_button aboveSubview:self];
}


-(void)drawRect:(CGRect)rect
{
    if(_pushButton)
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
    if(_radio == NO)
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
    
    
    if(_button.selected)
    {
        CGContextSaveGState(ctx);
        
        CGFloat margin = minDim/3;
        
        if(_radio)
        {
            
            CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
            CGContextAddEllipseInRect(ctx, CGRectMake(margin, margin, rect.size.width-2*margin, rect.size.height-2*margin));
            CGContextFillPath(ctx);
            
        }
        else if(_pushButton == NO)
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
    if([value isKindOfClass:[NSNull class]]==YES){
        self.value = nil;
        return;
    }
    
    if(_val!=value){
        _val = value;
    }
    
    if(_val){
        _button.selected = [_val isEqualToString:_exportValue];
    }
    else{
        _button.selected = NO;
    }
    [self refresh];
}

-(NSString*)value
{
    return _val;
}


-(void)updateWithZoom:(CGFloat)zoom
{
    [super updateWithZoom:zoom];

    CGFloat minDim = MIN(self.bounds.size.width,self.bounds.size.height)*0.85;
    CGPoint center = CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2);
    _button.frame = CGRectMake(center.x-minDim+self.frame.origin.x, center.y-minDim+self.frame.origin.y, minDim*2, minDim*2);
    if(_radio)
    _button.layer.cornerRadius = _button.frame.size.width/2;
    [self refresh];
    [_button setNeedsDisplay];
}



-(void)buttonPressed:(id)sender
{
    [self.delegate widgetAnnotationValueChanged:self];
}


#pragma mark - setter


-(void)setPushButton:(BOOL)pb
{
    _pushButton = pb;
    
    if(_pushButton)
    {
     
        self.backgroundColor = [UIColor whiteColor];
    }
    
}


-(void)setNoOff:(BOOL)no
{
    _noOff = no;
}

-(void)setRadio:(BOOL)rd
{
    _radio = rd;
}


@end
