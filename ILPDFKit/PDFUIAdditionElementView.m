
#import "PDFUIAdditionElementView.h"

@implementation PDFUIAdditionElementView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        _baseFrame = frame;
        _zoomScale = 1.0;
    }
    return self;
}


-(void)updateWithZoom:(CGFloat)zoom
{
    _zoomScale = zoom;
    self.frame = CGRectMake(_baseFrame.origin.x*zoom,_baseFrame.origin.y*zoom,_baseFrame.size.width*zoom,_baseFrame.size.height*zoom);
}


-(void)vectorRenderInPDFContext:(CGContextRef)ctx ForRect:(CGRect)rect
{
}

#pragma mark - Properties

-(void)setValue:(NSString *)value
{
}

-(NSString*)value
{
    return nil;
}

-(void)setOptions:(NSArray *)options
{
}

-(NSArray*)options
{
    return nil;
}

-(void)refresh
{
    [self setNeedsDisplay];
}

-(void)resign
{
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
        self.value = [change objectForKey:NSKeyValueChangeNewKey];
    }
    else if([keyPath isEqualToString:@"options"])
    {
        self.options = [change objectForKey:NSKeyValueChangeNewKey];
    }
}

@end
