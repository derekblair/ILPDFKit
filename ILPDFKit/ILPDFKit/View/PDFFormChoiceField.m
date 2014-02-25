//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFFormChoiceField.h"
#import <QuartzCore/QuartzCore.h>
#import "PDFView.h"
#import "PDF.h"

@interface PDFFormChoiceFieldDropIndicator : UIView
@end

@implementation PDFFormChoiceFieldDropIndicator



-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat margin = rect.size.width/3;
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(ctx, margin, margin);
    CGContextAddLineToPoint(ctx, rect.size.width-margin, rect.size.height/2);
    CGContextAddLineToPoint(ctx, margin, rect.size.height-margin);
    CGContextAddLineToPoint(ctx,margin,margin);
    CGContextFillPath(ctx);
}

@end

@implementation PDFFormChoiceField
{
    UITableView* _tv;
    NSArray* _options;
    NSUInteger _selectedIndex;
    UILabel* _selection;
    BOOL _dropped;
    PDFFormChoiceFieldDropIndicator* _dropIndicator;
    CGFloat _baseFontHeight;
    CGFloat _iPhoneCorrection;
}


-(void)dealloc
{
    [_tv release];
    self.options = nil;
    [_selection release];
    [_dropIndicator release];
    [super dealloc];
}


-(id)initWithFrame:(CGRect)frame Options:(NSArray*)opt 
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        self.opaque = NO;
        self.backgroundColor = [PDFWidgetColor colorWithAlphaComponent:1];
        self.layer.cornerRadius = self.frame.size.height/6;
        _options = [opt retain];
        _tv= [[UITableView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height*MIN(5,[_options count])) style:UITableViewStylePlain];
        _tv.dataSource = self;
        _tv.delegate = self;
        _tv.opaque = NO;
        _tv.backgroundColor = [UIColor clearColor];
        _tv.backgroundView = nil;
        _tv.alpha = 0;
        _tv.layer.cornerRadius = 4;
        _tv.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tv.separatorColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _baseFontHeight = MAX(floorf(frame.size.height)-2,12);
        
        _iPhoneCorrection = (iPad?1.0:0.8);
        
        _selection = [[UILabel alloc] initWithFrame:CGRectMake(1, 0, frame.size.width-frame.size.height, frame.size.height)];
        _selection.opaque = NO;
        _selection.adjustsFontSizeToFitWidth = YES;
        [_selection setBackgroundColor:[UIColor clearColor]];
        [_selection setTextColor:[UIColor blackColor]];
        [_selection setFont:[UIFont systemFontOfSize:_baseFontHeight*_iPhoneCorrection]];
        [self addSubview:_selection];
        _dropIndicator = [[PDFFormChoiceFieldDropIndicator alloc] initWithFrame:CGRectMake(frame.size.width-frame.size.height*1.5, -frame.size.height*0.25, frame.size.height*1.5, frame.size.height*1.5)];
        [_dropIndicator setOpaque:NO];
        [_dropIndicator setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_dropIndicator];
        
        
        UIButton* middleButton = [[UIButton alloc] initWithFrame:self.bounds];
        middleButton.opaque = NO;
        middleButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        middleButton.backgroundColor = [UIColor clearColor];
        [middleButton addTarget:self action:@selector(dropButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:middleButton];
        [middleButton release];
        [self addSubview:_tv];
       
    }
    
    return self;
}

#pragma mark - PDFUIElement

-(void)setValue:(NSString*)value
{
    if([value isKindOfClass:[NSNull class]])
    {
        self.value = nil;
        return;
    }
    
    if(value!=nil)
    {
        NSUInteger nind = [_options indexOfObject:value];
        _selectedIndex = nind;
    }
    else
    {
        _selectedIndex = NSNotFound;
    }
    
    [_selection setText:value];
    [self refresh];
}

-(void)setOptions:(NSArray*)opt
{
    if([opt isKindOfClass:[NSNull class]])
    {
        self.options = nil;
        return;
    }
    if(_options!=opt)
    {
        [_options release];
        _options = [opt retain];
    }
    CGFloat sf = _selection.frame.size.height;
    _tv.frame = CGRectMake(0, sf, self.frame.size.width, sf*MIN(5,[_options count]));
}

-(NSArray*)options
{
    return _options;
}

-(void)refresh
{
    [super refresh];
    CGFloat sf = _selection.frame.size.height;
    _tv.frame = CGRectMake(0, sf, self.frame.size.width, sf*MIN(5,[_options count]));
    [_tv reloadData];
    [_tv selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

-(NSString*)value
{
    return [_selection.text length]?_selection.text:nil;
}

-(void)updateWithZoom:(CGFloat)zoom
{
    [super updateWithZoom:zoom];
    _dropIndicator.frame = CGRectMake(self.frame.size.width-self.frame.size.height*1.5, -self.frame.size.height*0.25, self.frame.size.height*1.5, self.frame.size.height*1.5);
    _selection.frame  = CGRectMake(1, 0, self.frame.size.width, self.frame.size.height);
    [_selection setFont:[UIFont systemFontOfSize:_baseFontHeight*zoom*(iPad?1.0:0.6)]];
    _dropIndicator.transform = CGAffineTransformMakeRotation(0);
    [_dropIndicator setNeedsDisplay];
    _tv.alpha = 0;
    _tv.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height*MIN(5,[_options count]));
    [self setNeedsDisplay];
}

-(void)vectorRenderInPDFContext:(CGContextRef)ctx ForRect:(CGRect)rect
{
    NSString* text = [(id)_selection text];
    UIFont* font = [UIFont systemFontOfSize:_baseFontHeight*(iPad?1.0:0.6)];
    NSTextAlignment align = (NSTextAlignment)[(id)_selection textAlignment];
    UIGraphicsPushContext(ctx);
    CGContextTranslateCTM(ctx, 0, (rect.size.height-_baseFontHeight)/2);

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = align;
    [text drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height) withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName: paragraphStyle}];
    [paragraphStyle release];
    
    UIGraphicsPopContext();
}

#pragma mark - UITableViewDataSource

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.opaque = NO;
    cell.indentationWidth = 0;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.opaque = NO;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.opaque = NO;
    [cell.textLabel setFont:[UIFont systemFontOfSize:MAX([self tableView:tableView heightForRowAtIndexPath:indexPath]*0.8,_baseFontHeight)*(iPad?1.0:0.7)]];
    cell.textLabel.text = [_options objectAtIndex:indexPath.row];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.bounds.size.height/MIN(5,[_options count]);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setValue:[_options objectAtIndex:indexPath.row]];
    [_delegate widgetAnnotationValueChanged:self];
}


#pragma mark - Responder

-(void)dropButtonPressed:(id)sender
{
    if(_dropped == NO)
    {
        [_delegate widgetAnnotationEntered:self];
    }
    _dropped = !_dropped;
    
    [_dropIndicator setNeedsDisplay];
    
    if(_dropped)
    {
        ((PDFView*)(self.superview.superview.superview)).activeWidgetAnnotationView = self;
        [_tv reloadData];
        
        if(_selectedIndex < [_options count])
        {
            [_tv selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [_tv scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height*MIN(6,[_options count]+1));
        _tv.alpha = 1.0f;
            _dropIndicator.transform = CGAffineTransformMakeRotation(M_PI/2);
        } completion:^(BOOL d){}];
    }
    else 
    {
        ((PDFView*)(self.superview.superview.superview)).activeWidgetAnnotationView = nil;
        [UIView animateWithDuration:0.3 animations:^{
            _tv.alpha = 0;
            self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height/MIN(6,[_options count]+1));
            _dropIndicator.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL d){}];
    }
    [self setNeedsDisplay];
}


-(void)resign
{
    if(_dropped == YES)[self dropButtonPressed:_dropIndicator];
    
}



@end
