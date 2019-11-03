//
//  ILPDFSignatureEditingView.m
//  Pods
//
//  Created by Yuriy on 28/08/16.
//
//

#import "ILPDFSignatureEditingView.h"

@implementation ILPDFSignatureEditingView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}

- (UIImage*) createImageFromSignWithMaxWidth:(CGFloat) width andMaxHeight:(CGFloat) height {
    
    CGRect rect = [self bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage* resizedImage = [self imageWithImage:img scaledToMaxWidth:width maxHeight:height];
    return resizedImage;
    
}

//resizing
- (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    
    CGSize newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(newSize);
    
    //get new size to keep proportion
    CGFloat scaleW = newSize.width / image.size.width;
    CGFloat scaleH = newSize.height / image.size.height;
    CGFloat widthNew = 0.f;
    CGFloat heigtNew = 0.f;
    CGFloat insetX = 0.f;
    CGFloat insetY = 0.f;
    
    if (scaleW>scaleH) {
        widthNew = newSize.width * image.size.height / image.size.width;
        heigtNew = newSize.height;
        insetX = newSize.width - widthNew;
    } else {
        heigtNew = newSize.height * image.size.height / image.size.width;
        widthNew = newSize.width ;
        insetY = newSize.height - heigtNew;
    }

    
    [image drawInRect:CGRectMake(insetX/2, insetY/2, widthNew, heigtNew)];
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:4.0];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:4.0];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [incrementalImage drawInRect:rect];
    [path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView* superView = self.superview;
    while (superView != nil) {
        if ([superView isKindOfClass:[UIScrollView class]]) {
            UIScrollView* superScroll = (UIScrollView*)superView;
            superScroll.scrollEnabled = NO;
        }
        
        superView = superView.superview;
    }
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView* superView = self.superview;
    while (superView != nil) {
        if ([superView isKindOfClass:[UIScrollView class]]) {
            UIScrollView* superScroll = (UIScrollView*)superView;
            superScroll.scrollEnabled = YES;
        }
        
        superView = superView.superview;
    }
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    
    if (!incrementalImage) // first time; paint background white
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void) clearSignature {
    
    incrementalImage = nil;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor whiteColor] setFill];
    [rectpath fill];
    UIGraphicsEndImageContext();
    [self setNeedsDisplay];
}


@end
