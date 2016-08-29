// ILPDFFormChoiceField.m
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
#import "ILPDFFormChoiceField.h"

#define ILPDFChoiceFieldRowHeightDivisor MIN(5,[self.options count])

@interface ILPDFFormChoiceFieldDropIndicator : UIView
@end

@implementation ILPDFFormChoiceFieldDropIndicator

- (void)drawRect:(CGRect)rect {
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

@interface ILPDFFormChoiceField(TableView) <UITableViewDelegate,UITableViewDataSource>
@end

@implementation ILPDFFormChoiceField {
    UITableView *_tv;
    NSArray *_options;
    NSUInteger _selectedIndex;
    UILabel *_selection;
    BOOL _dropped;
    ILPDFFormChoiceFieldDropIndicator *_dropIndicator;
    CGFloat _baseFontHeight;
}


#pragma mark - UIView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    NSAssert(NO,@"Non-Supported Initializer");
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame options:@[]];
    return self;
}


#pragma mark - ILPDFFormChoiceField

- (instancetype)initWithFrame:(CGRect)frame options:(NSArray *)opt {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.opaque = NO;
        self.backgroundColor = [ILPDFWidgetColor colorWithAlphaComponent:1];
        self.layer.cornerRadius = self.frame.size.height/6;
        _options = opt;
        _tv= [[UITableView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height*ILPDFChoiceFieldRowHeightDivisor) style:UITableViewStylePlain];
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
        _baseFontHeight = [ILPDFWidgetAnnotationView fontSizeForRect:frame value:nil multiline:NO choice:YES];
        _selection = [[UILabel alloc] initWithFrame:CGRectMake(1, 0, frame.size.width-frame.size.height, frame.size.height)];
        _selection.opaque = NO;
        _selection.adjustsFontSizeToFitWidth = YES;
        [_selection setBackgroundColor:[UIColor clearColor]];
        [_selection setTextColor:[UIColor blackColor]];
        [_selection setFont:[UIFont systemFontOfSize:_baseFontHeight]];
        [self addSubview:_selection];
        _dropIndicator = [[ILPDFFormChoiceFieldDropIndicator alloc] initWithFrame:CGRectMake(frame.size.width-frame.size.height*1.5, -frame.size.height*0.25, frame.size.height*1.5, frame.size.height*1.5)];
        [_dropIndicator setOpaque:NO];
        [_dropIndicator setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_dropIndicator];
        UIButton *middleButton = [[UIButton alloc] initWithFrame:self.bounds];
        middleButton.opaque = NO;
        middleButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        middleButton.backgroundColor = [UIColor clearColor];
        [middleButton addTarget:self action:@selector(dropButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:middleButton];
        [self addSubview:_tv];
    }
    return self;
}

#pragma mark - ILPDFWidgetAnnotationView

- (NSString *)value {
    return [_selection.text length] ? _selection.text:nil;
}

- (void)setValue:(NSString *)value {
    if ([value isKindOfClass:[NSNull class]]) {
        self.value = nil;
        return;
    }
    if (value != nil) {
        NSUInteger nind = [_options indexOfObject:value];
        _selectedIndex = nind;
    } else {
        _selectedIndex = NSNotFound;
    }
    [_selection setText:value];
    [self refresh];
}

- (void)setOptions:(NSArray *)opt {
    if ([opt isKindOfClass:[NSNull class]]) {
        self.options = nil;
        return;
    }
    if (_options != opt) {
        _options = opt;
    }
    CGFloat sf = _selection.frame.size.height;
    _tv.frame = CGRectMake(0, sf, self.frame.size.width, sf*ILPDFChoiceFieldRowHeightDivisor);
}

- (NSArray *)options {
    return _options;
}

- (void)refresh {
    [super refresh];
    CGFloat sf = _selection.frame.size.height;
    _tv.frame = CGRectMake(0, sf, self.frame.size.width, sf*ILPDFChoiceFieldRowHeightDivisor);
    [_tv reloadData];
    [_tv selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)resign {
    if (_dropped) [self dropButtonPressed:_dropIndicator];
}

- (void)updateWithZoom:(CGFloat)zoom {
    [super updateWithZoom:zoom];
    _dropIndicator.frame = CGRectMake(self.frame.size.width-self.frame.size.height*1.5, -self.frame.size.height*0.25, self.frame.size.height*1.5, self.frame.size.height*1.5);
    _selection.frame  = CGRectMake(1, 0, self.frame.size.width-self.frame.size.height, self.frame.size.height);
    [_selection setFont:[UIFont systemFontOfSize:_baseFontHeight*zoom]];
    _dropIndicator.transform = CGAffineTransformMakeRotation(0);
    [_dropIndicator setNeedsDisplay];
    _tv.alpha = 0;
    _tv.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height*ILPDFChoiceFieldRowHeightDivisor);
    [self setNeedsDisplay];
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.opaque = NO;
    cell.indentationWidth = 0;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.opaque = NO;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.opaque = NO;
    [cell.textLabel setFont:[UIFont systemFontOfSize:_selection.font.pointSize]];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = _options[indexPath.row];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_options count];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.bounds.size.height/ILPDFChoiceFieldRowHeightDivisor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setValue:_options[indexPath.row]];
    [self.delegate widgetAnnotationValueChanged:self];
}

#pragma mark - Responder

- (void)dropButtonPressed:(id)sender {
    [self.superview bringSubviewToFront:self];
    if (!_dropped) {
        [self.delegate widgetAnnotationEntered:self];
    }
    _dropped = !_dropped;
    [_dropIndicator setNeedsDisplay];
    if (_dropped) {
        self.parentView.activeWidgetAnnotationView = self;
        [_tv reloadData];
        if (_selectedIndex < [_options count]) {
            [_tv selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [_tv scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height*(ILPDFChoiceFieldRowHeightDivisor+1));
            _tv.alpha = 1.0f;
            _dropIndicator.transform = CGAffineTransformMakeRotation(M_PI/2);
        } completion:^(BOOL d){}];
    } else {
        self.parentView.activeWidgetAnnotationView = nil;
        [UIView animateWithDuration:0.3 animations:^{
            _tv.alpha = 0;
            self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height/(ILPDFChoiceFieldRowHeightDivisor+1));
            _dropIndicator.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL d){}];
    }
    [self setNeedsDisplay];
}


@end
