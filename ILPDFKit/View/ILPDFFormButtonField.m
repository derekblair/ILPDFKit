// ILPDFFormButtonField.m
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
#import <ILPDFKit/ILPDFKit.h>
#import "ILPDFFormButtonField.h"

#define ILPDFButtonMinScaledDimensionScaleFactor 0.85
#define ILPDFButtonMinScaledDimension(r) MIN((r).size.width,(r).size.height)*ILPDFButtonMinScaledDimensionScaleFactor
#define ILPDFButtonMarginScaleFactor 0.75

@implementation ILPDFFormButtonField {
    NSString *_val;
    UIButton *_button;
}

#pragma mark - UIView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    NSAssert(NO,@"Non-Supported Initializer");
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame radio:NO];
    return self;
}


- (void)drawRect:(CGRect)rect {
    if (_pushButton) {
        [super drawRect:rect];
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [ILPDFFormButtonField drawWithRect:rect context:ctx back:YES selected:_button.selected radio:_radio];
}

#pragma mark - ILPDFWidgetAnnotationView

- (void)setValue:(NSString *)value {
    if ([value isKindOfClass:[NSNull class]]) {
        self.value = nil;
        return;
    }
    if (_val != value) {
        _val = value;
    }
    if (_val) {
        _button.selected = [_val isEqualToString:_exportValue];
    } else {
        _button.selected = NO;
    }
    [self refresh];
}

- (NSString *)value {
    return _val;
}

- (void)updateWithZoom:(CGFloat)zoom {
    [super updateWithZoom:zoom];
    CGFloat minDim = ILPDFButtonMinScaledDimension(self.bounds);
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    _button.frame = CGRectMake(center.x-minDim+self.frame.origin.x, center.y-minDim+self.frame.origin.y, minDim*2, minDim*2);
    if (_radio) _button.layer.cornerRadius = _button.frame.size.width/2;
    [self refresh];
    [_button setNeedsDisplay];
}

#pragma mark - ILPDFFormButtonField
#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame radio:(BOOL)rad {
    self = [super initWithFrame:frame];
    if (self) {
        _radio = rad;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat minDim = ILPDFButtonMinScaledDimension(self.bounds);
        CGPoint center = CGPointMake(frame.size.width/2,frame.size.height/2);
        _button.frame = CGRectMake(center.x-minDim, center.y-minDim, minDim*2, minDim*2);
        if (_radio) _button.layer.cornerRadius = _button.frame.size.width/2;
        _button.opaque = NO;
        _button.backgroundColor = [UIColor clearColor];
        [self addSubview:_button];
        [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.userInteractionEnabled = NO;
        _button.userInteractionEnabled  = YES;
    }
    return self;
}

- (void)setButtonSuperview {
    [_button removeFromSuperview];
    CGRect frame = self.bounds;
    CGFloat minDim = ILPDFButtonMinScaledDimension(self.bounds);
    CGPoint center = CGPointMake(frame.size.width/2,frame.size.height/2);
    _button.frame = CGRectMake(center.x-minDim+self.frame.origin.x, center.y-minDim+self.frame.origin.y, 2*minDim,2*minDim);
    [self.superview insertSubview:_button aboveSubview:self];
}

#pragma mark - Responders

- (void)buttonPressed:(id)sender {
    [self.delegate widgetAnnotationValueChanged:self];
}

#pragma mark - Getters/Setters

- (void)setPushButton:(BOOL)pb {
    _pushButton = pb;
}

- (void)setNoOff:(BOOL)no {
    _noOff = no;
}

- (void)setRadio:(BOOL)rd {
    _radio = rd;
}

#pragma mark - Rendering

+ (void)drawWithRect:(CGRect)frame context:(CGContextRef)ctx back:(BOOL)back selected:(BOOL)selected radio:(BOOL)radio {
    CGFloat minDim = ILPDFButtonMinScaledDimension(frame);
    CGPoint center = CGPointMake(frame.size.width/2,frame.size.height/2);
    CGRect rect = CGRectMake(center.x-minDim/2, center.y-minDim/2, minDim, minDim);
    if (back) {
        CGContextSaveGState(ctx);
        CGContextSetFillColorWithColor(ctx,ILPDFWidgetColor.CGColor);
        if (!radio) {
            CGContextRef context = ctx;
            CGFloat radius = minDim/6;
            CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
            CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
            CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,radius, M_PI, M_PI / 2, 1);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,rect.origin.y + rect.size.height);
            CGContextAddArc(context, rect.origin.x + rect.size.width - radius,rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
            CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,radius, 0.0f, -M_PI / 2, 1);
            CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
            CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,-M_PI / 2, M_PI, 1);
            CGContextFillPath(context);
        } else {
            CGContextFillEllipseInRect(ctx, rect);
        }
        CGContextRestoreGState(ctx);
    }
    if (selected) {
        CGContextSaveGState(ctx);
        CGFloat margin = minDim/3;
        if (radio) {
            CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
            CGContextAddEllipseInRect(ctx, CGRectMake(margin, margin, rect.size.width-2*margin, rect.size.height-2*margin));
            CGContextFillPath(ctx);
        } else {
            CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
            CGContextSetLineWidth(ctx, rect.size.width/8);
            CGContextSetLineCap(ctx,kCGLineCapRound);
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextMoveToPoint(ctx, margin*ILPDFButtonMarginScaleFactor, rect.size.height/2);
            CGContextAddLineToPoint(ctx, rect.size.width/2-margin/4, rect.size.height-margin);
            CGContextAddLineToPoint(ctx, rect.size.width-margin*ILPDFButtonMarginScaleFactor, margin/2);
            CGContextStrokePath(ctx);
        }
        CGContextRestoreGState(ctx);
    }
}

@end
