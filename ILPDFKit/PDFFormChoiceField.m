
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


-(void)dealloc
{
    [tv release];
    self.options = nil;
    [selection release];
    [dropIndicator release];
    [super dealloc];
}


-(id)initWithFrame:(CGRect)frame Options:(NSArray*)opt 
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        self.opaque = NO;
        self.backgroundColor = [PDFWidgetColor colorWithAlphaComponent:1];
        self.layer.cornerRadius = 4;
        options = [opt retain];
        tv= [[UITableView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height*MIN(5,[options count])) style:UITableViewStylePlain];
        tv.dataSource = self;
        tv.delegate = self;
        tv.opaque = NO;
        tv.backgroundColor = [UIColor clearColor];
        tv.backgroundView = nil;
        tv.alpha = 0;
        tv.layer.cornerRadius = 4;
        tv.separatorStyle = UITableViewCellSeparatorStyleNone;
        tv.separatorColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        selection = [[UILabel alloc] initWithFrame:CGRectMake(1, 0, frame.size.width-frame.size.height, frame.size.height)];
        selection.opaque = NO;
        selection.adjustsFontSizeToFitWidth = YES;
        selection.minimumFontSize = 10;
        [selection setBackgroundColor:[UIColor clearColor]];
        [selection setTextColor:[UIColor blackColor]];
        [selection setFont:[UIFont systemFontOfSize:16]];
        [self addSubview:selection];
        dropIndicator = [[PDFFormChoiceFieldDropIndicator alloc] initWithFrame:CGRectMake(frame.size.width-frame.size.height*1.5, -frame.size.height*0.25, frame.size.height*1.5, frame.size.height*1.5)];
        [dropIndicator setOpaque:NO];
        [dropIndicator setBackgroundColor:[UIColor clearColor]];
        [self addSubview:dropIndicator];
        
        
        UIButton* middleButton = [[UIButton alloc] initWithFrame:self.bounds];
        middleButton.opaque = NO;
        middleButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        middleButton.backgroundColor = [UIColor clearColor];
        [middleButton addTarget:self action:@selector(dropButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:middleButton];
        [middleButton release];
        [self addSubview:tv];
       
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
        NSUInteger nind = [options indexOfObject:value];
        selectedIndex = nind;
    }
    else
    {
        selectedIndex = NSNotFound;
    }
    
    [selection setText:value];
    [self refresh];
}

-(void)setOptions:(NSArray*)opt
{
    if([opt isKindOfClass:[NSNull class]])
    {
        self.options = nil;
        return;
    }
    if(options!=opt)
    {
        [options release];
        options = [opt retain];
    }
    CGFloat sf = selection.frame.size.height;
    tv.frame = CGRectMake(0, sf, self.frame.size.width, sf*MIN(5,[options count]));
}

-(NSArray*)options
{
    return options;
}

-(void)refresh
{
    [super refresh];
    CGFloat sf = selection.frame.size.height;
    tv.frame = CGRectMake(0, sf, self.frame.size.width, sf*MIN(5,[options count]));
    [tv reloadData];
    [tv selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

-(NSString*)value
{
    return [selection.text length]?selection.text:nil;
}

-(void)updateWithZoom:(CGFloat)zoom
{
    [super updateWithZoom:zoom];
    dropIndicator.frame = CGRectMake(self.frame.size.width-self.frame.size.height*1.5, -self.frame.size.height*0.25, self.frame.size.height*1.5, self.frame.size.height*1.5);
    selection.frame  = CGRectMake(1, 0, self.frame.size.width, self.frame.size.height);
    [selection setFont:[UIFont systemFontOfSize:16*zoom]];
    dropIndicator.transform = CGAffineTransformMakeRotation(0);
    [dropIndicator setNeedsDisplay];
    tv.alpha = 0;
    tv.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height*MIN(5,[options count]));
    [self setNeedsDisplay];
}

-(void)vectorRenderInPDFContext:(CGContextRef)ctx ForRect:(CGRect)rect
{
    NSString* text = [(id)selection text];
    UIFont* font = [UIFont systemFontOfSize:16];
    NSTextAlignment align = (NSTextAlignment)[(id)selection textAlignment];
    UIGraphicsPushContext(ctx);
        CGContextTranslateCTM(ctx, 0, (rect.size.height-16)/2);
        [text drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height) withFont:font lineBreakMode:NSLineBreakByWordWrapping  alignment:align];
    
    UIGraphicsPopContext();
}

#pragma mark - UITableViewDataSource

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.opaque = NO;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.opaque = NO;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.opaque = NO;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumFontSize = 10;
    [cell.textLabel setFont:[UIFont systemFontOfSize:MAX(0.5*tableView.bounds.size.height/5,12)]];
    cell.textLabel.text = [options objectAtIndex:indexPath.row];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [options count];
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.bounds.size.height/MIN(5,[options count]);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setValue:[options objectAtIndex:indexPath.row]];
    [delegate uiAdditionValueChanged:self];
}


#pragma mark - Responder

-(void)dropButtonPressed:(id)sender
{
    if(dropped == NO)
    {
        [delegate uiAdditionEntered:self];
    }
    dropped = !dropped;
    
    [dropIndicator setNeedsDisplay];
    
    if(dropped)
    {
        ((PDFView*)(self.superview.superview.superview)).activeUIAdditionsView = self;
        [tv reloadData];
        
        if(selectedIndex < [options count])
        {
            [tv selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [tv scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height*MIN(6,[options count]+1));
        tv.alpha = 1.0f;
            dropIndicator.transform = CGAffineTransformMakeRotation(M_PI/2);
        } completion:^(BOOL d){}];
    }
    else 
    {
        ((PDFView*)(self.superview.superview.superview)).activeUIAdditionsView = nil;
        [UIView animateWithDuration:0.3 animations:^{
            tv.alpha = 0;
            self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height/MIN(6,[options count]+1));
            dropIndicator.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL d){}];
    }
    [self setNeedsDisplay];
}


-(void)resign
{
    if(dropped == YES)[self dropButtonPressed:dropIndicator];
    
}



@end
