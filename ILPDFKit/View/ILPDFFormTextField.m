// ILPDFFormTextField.m
//
// Copyright (c) 2017 Derek Blair
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
#import "ILPDFFormTextField.h"

@interface ILPDFFormTextField(Delegates) <UITextViewDelegate,UITextFieldDelegate>
@end

@interface ILPDFFormTextFieldPercentFormat : NSObject
@property (nonatomic) NSInteger nDec;
@property (nonatomic) NSInteger sepStyle;
@end

@implementation ILPDFFormTextFieldPercentFormat
@end

@implementation ILPDFFormTextField {
    BOOL _multiline;
    UIView *_textFieldOrTextView;
    CGFloat _baseFontSize;
    CGFloat _currentFontSize;
    NSString *_dateFormat;
    ILPDFFormTextFieldPercentFormat *_percentFormat;
}

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
    removeObserver:self];
}

#pragma mark - UIView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    NSAssert(NO,@"Non-Supported Initializer");
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame multiline:NO alignment:NSTextAlignmentLeft secureEntry:NO readOnly:NO];
    return self;
}

#pragma mark - ILPDFFormTextField


- (instancetype)initWithFrame:(CGRect)frame multiline:(BOOL)multiline alignment:(NSTextAlignment)alignment secureEntry:(BOOL)secureEntry readOnly:(BOOL)ro {

    self = [super initWithFrame:frame];
    if (self != nil) {
        self.opaque = NO;
        self.backgroundColor = ro ? [UIColor clearColor]:ILPDFWidgetColor;
        if (!multiline) {
            self.layer.cornerRadius = self.frame.size.height/6;
        }
        _multiline = multiline;
        Class textCls = multiline ? [UITextView class]:[UITextField class];
        _textFieldOrTextView = [[textCls alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        if (secureEntry) {
            ((UITextField *)_textFieldOrTextView).secureTextEntry = YES;
        }
        if (ro) {
            _textFieldOrTextView.userInteractionEnabled = NO;
        }
        if (multiline) {
            ((UITextView *)_textFieldOrTextView).textAlignment = (NSTextAlignment)alignment;
            ((UITextView *)_textFieldOrTextView).autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            ((UITextView *)_textFieldOrTextView).delegate = self;
            ((UITextView *)_textFieldOrTextView).scrollEnabled = YES;
            [((UITextView *)_textFieldOrTextView) setTextContainerInset:UIEdgeInsetsMake(4, 4, 4, 4)];
        } else {
            ((UITextField *)_textFieldOrTextView).textAlignment = (NSTextAlignment)alignment;
            ((UITextField *)_textFieldOrTextView).delegate = self;
            ((UITextField *)_textFieldOrTextView).adjustsFontSizeToFitWidth = YES;
            ((UITextField *)_textFieldOrTextView).minimumFontSize = ILPDFFormMinFontSize;
            ((UITextField *)_textFieldOrTextView).autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextFieldTextDidChangeNotification object:_textFieldOrTextView];
        }
        _textFieldOrTextView.opaque = NO;
        _textFieldOrTextView.backgroundColor = [UIColor clearColor];
        [(id)_textFieldOrTextView setInputAccessoryView:[self makeInputAccessoryToolbar]];
        _baseFontSize = [ILPDFWidgetAnnotationView fontSizeForRect:frame value:nil multiline:multiline choice:NO];
        _currentFontSize = _baseFontSize;
        [_textFieldOrTextView performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:_baseFontSize]];
        [self addSubview:_textFieldOrTextView];
    }
    return self;
}


- (UIToolbar *)makeInputAccessoryToolbar {
    static CGFloat const ILTextFieldInputAccessoryToolbarHeight = 44.0;

    UIToolbar *nextAndPreviousToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ILTextFieldInputAccessoryToolbarHeight)];
    nextAndPreviousToolbar.userInteractionEnabled = YES;
    nextAndPreviousToolbar.opaque = YES;
    UIBarButtonItem *nextField = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(next:)];
    UIBarButtonItem *prevField = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleDone target:self action:@selector(previous:)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    nextAndPreviousToolbar.items = @[prevField,flexSpace,nextField];
    return nextAndPreviousToolbar;
}


- (UIView *)textFieldOrTextView {
    return _textFieldOrTextView;
}

#pragma mark - ILPDFWidgetAnnotationView

- (void)setValue:(NSString *)value {
    if ([value isKindOfClass:[NSNull class]]) {
        [self setValue:nil];
        return;
    }
    [_textFieldOrTextView performSelector:@selector(setText:) withObject:value];
    [self refresh];
}

- (NSString *)value {
    NSString *ret = [_textFieldOrTextView performSelector:@selector(text)];
    return [ret length] ? ret:nil;
}

- (void)updateWithZoom:(CGFloat)zoom {
    [super updateWithZoom:zoom];
    [_textFieldOrTextView performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:_currentFontSize = _baseFontSize*zoom]];
    [_textFieldOrTextView setNeedsDisplay];
    [self setNeedsDisplay];
}

- (void)refresh {
    [self setNeedsDisplay];
    [_textFieldOrTextView setNeedsDisplay];
}

#pragma mark - Notification Responders

- (void)textChanged:(id)sender {
    [self.delegate widgetAnnotationValueChanged:self];
}

#pragma mark - Toolbar Responders

- (void)next:(id)sender {
    [self.textFieldOrTextView resignFirstResponder];
    [[self nextField].textFieldOrTextView becomeFirstResponder];
}

- (void)previous:(id)sender {
    [self.textFieldOrTextView resignFirstResponder];
    [[self previousField].textFieldOrTextView becomeFirstResponder];
}

#pragma mark - Custom Formatting


- (void)configureAsPercentField:(NSInteger)nDec seperatorStyle:(NSInteger)seperatorStyle {
    ILPDFFormTextFieldPercentFormat *format = [ILPDFFormTextFieldPercentFormat new];
    format.nDec = nDec;
    format.sepStyle = seperatorStyle;
    _percentFormat = format;
    ((UITextField *)(self.textFieldOrTextView)).keyboardType = UIKeyboardTypeDecimalPad;

    [self updateFormattedText:((UITextField *)(self.textFieldOrTextView))];
}

- (void)configureAsDateFieldWithFormat:(NSString *)format {

    UIDatePicker * picker = [[UIDatePicker alloc] init];
    _dateFormat = format;
    _dateFormat = [_dateFormat stringByReplacingOccurrencesOfString:@"m" withString:@"M"];
    _dateFormat = [_dateFormat stringByReplacingOccurrencesOfString:@":MM" withString:@":mm"];
    _dateFormat = [_dateFormat stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    _dateFormat = [_dateFormat stringByReplacingOccurrencesOfString:@"'" withString:@""];
    _dateFormat = [_dateFormat stringByReplacingOccurrencesOfString:@"`" withString:@""];

    if ([format containsString:@":"]) {
        picker.datePickerMode = UIDatePickerModeDateAndTime;
    } else {
        picker.datePickerMode = UIDatePickerModeDate;
    }

    [picker addTarget:self action:@selector(datePickerSelectionChanged:) forControlEvents:UIControlEventValueChanged];


    if ([_textFieldOrTextView isKindOfClass:UITextField.class]) {
        ((UITextField *)_textFieldOrTextView).inputView = picker;
    }

}

- (void)updateFormattedText:(UITextField *)textField {
    if (_dateFormat) {
        [self datePickerSelectionChanged:(UIDatePicker *)(((UITextField *)_textFieldOrTextView).inputView)];
    } else if (_percentFormat) {

        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.usesGroupingSeparator = YES;
        formatter.groupingSeparator = @",";
        formatter.maximumFractionDigits = _percentFormat.nDec;
        formatter.minimumFractionDigits = _percentFormat.nDec;
        textField.text = [[NSString stringWithFormat:@"%@",[formatter stringFromNumber:@([textField.text floatValue]*100)]] stringByAppendingString:@"%"];
         [self.delegate widgetAnnotationValueChanged:self];
        
    }
}

- (void)datePickerSelectionChanged:(UIDatePicker *)sender {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = _dateFormat;
    ((UITextField *)(self.textFieldOrTextView)).text = [formatter stringFromDate:sender.date];
     [self.delegate widgetAnnotationValueChanged:self];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.delegate widgetAnnotationEntered:self];
    self.parentView.activeWidgetAnnotationView = self;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.parentView.activeWidgetAnnotationView = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.delegate widgetAnnotationValueChanged:self];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    CGSize contentSize = CGSizeMake(textView.bounds.size.width-ILPDFFormMinFontSize, CGFLOAT_MAX);
    float numLines = ceilf((textView.bounds.size.height / textView.font.lineHeight));
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([newString length] < [textView.text length]) return YES;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGRect textRect = [newString boundingRectWithSize:contentSize
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName:textView.font,NSParagraphStyleAttributeName:paragraphStyle}
                                        context:nil];
    float usedLines = ceilf(textRect.size.height/textView.font.lineHeight);
    if (usedLines >= numLines && usedLines > 1) return NO;
    return YES;
}


#pragma mark - UITextFieldDelegate


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newString length] <= [textField.text length]) return YES;
    if ([newString sizeWithAttributes:@{NSFontAttributeName:textField.font}].width > (textField.bounds.size.width + ILPDFFormMinFontSize)) {
       return NO;
    }
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.returnKeyType == UIReturnKeyNext) {
        [[self nextField].textFieldOrTextView becomeFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate widgetAnnotationEntered:self];
     self.parentView.activeWidgetAnnotationView = self;

    if (_percentFormat) {
        float f = [[[textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] floatValue]/100;
        NSString *format = [[@"%." stringByAppendingString:[NSString stringWithFormat:@"%@",@(_percentFormat.nDec)]] stringByAppendingString:@"f"];
        textField.text = [NSString stringWithFormat:format,f];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateFormattedText:textField];
    self.parentView.activeWidgetAnnotationView = nil;
}

- (void)resign {
    [_textFieldOrTextView resignFirstResponder];
}

@end





@implementation ILPDFFormTextField(NextField)


static CGFloat const ILTextFieldTabbingSortVariance = 8.0;

+ (void)addTextWidgetAnnotationViewsToArray:(NSMutableArray<ILPDFFormTextField *> *)arr view:(UIView *)view {
    for (UIView *v in view.subviews) {
        if (([v isKindOfClass:ILPDFFormTextField.class]) && !v.hidden && ((ILPDFFormTextField *)v).textFieldOrTextView.userInteractionEnabled) {
            [arr addObject:(ILPDFFormTextField *)v];
        } else {
             [self addTextWidgetAnnotationViewsToArray:arr view:v];
        }
    }
}



- (ILPDFFormTextField *)nextField {
    ILPDFFormTextField *textField = self;
    UIView *sv = textField.window;
    NSMutableArray *possibleFields = [NSMutableArray array];
    [ILPDFFormTextField addTextWidgetAnnotationViewsToArray:possibleFields view:sv];

    CGPoint (^wp)(ILPDFFormTextField *) = ^CGPoint(ILPDFFormTextField *v) {
        return [v convertPoint:v.textFieldOrTextView.frame.origin toView:sv];
    };

    NSMutableArray<ILPDFFormTextField *> *array = [NSMutableArray array];
    for (ILPDFFormTextField *v in possibleFields) {
        if (v != textField) {
            if ((wp(v).y >= wp(textField).y + ILTextFieldTabbingSortVariance) || (wp(v).y >= wp(textField).y - ILTextFieldTabbingSortVariance/2 && wp(v).x > wp(textField).x)) [array addObject:(ILPDFFormTextField *)v];
        }
    }
    if (array.count) {
        [array sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
            ILPDFFormTextField *tx1 = (ILPDFFormTextField *)obj1;
            ILPDFFormTextField *tx2 = (ILPDFFormTextField *)obj2;
            if (wp(tx1).y >= wp(tx2).y + ILTextFieldTabbingSortVariance) {
                return NSOrderedAscending;
            } else if (wp(tx1).y <= wp(tx2).y - ILTextFieldTabbingSortVariance) {
                return NSOrderedDescending;
            } else {
                if (wp(tx1).x > wp(tx2).x) {
                    return NSOrderedAscending;
                } else if (wp(tx1).x < wp(tx2).x) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        return [array lastObject];
    } else {
        return nil;
    }
}

- (ILPDFFormTextField *)previousField {
    ILPDFFormTextField *textField = self;
    UIView *sv = textField.window;
    NSMutableArray *possibleFields = [NSMutableArray array];
    [ILPDFFormTextField addTextWidgetAnnotationViewsToArray:possibleFields view:sv];

    CGPoint (^wp)(ILPDFFormTextField *) = ^CGPoint(ILPDFFormTextField *v) {
        return [v convertPoint:v.textFieldOrTextView.frame.origin toView:sv];
    };

    NSMutableArray<ILPDFFormTextField *> *array = [NSMutableArray array];
    for (ILPDFFormTextField *v in possibleFields) {
        if (v != textField) {
            if ((wp(v).y <= wp(textField).y - ILTextFieldTabbingSortVariance) || (wp(v).y <= wp(textField).y + ILTextFieldTabbingSortVariance/2 && wp(v).x < wp(textField).x)) [array addObject:(ILPDFFormTextField *)v];
        }
    }
    if (array.count) {
        [array sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
            ILPDFFormTextField *tx1 = (ILPDFFormTextField *)obj1;
            ILPDFFormTextField *tx2 = (ILPDFFormTextField *)obj2;
            if (wp(tx1).y >= wp(tx2).y + ILTextFieldTabbingSortVariance) {
                return NSOrderedAscending;
            } else if (wp(tx1).y <= wp(tx2).y - ILTextFieldTabbingSortVariance) {
                return NSOrderedDescending;
            } else {
                if (wp(tx1).x > wp(tx2).x) {
                    return NSOrderedAscending;
                } else if (wp(tx1).x < wp(tx2).x) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        return [array firstObject];
    } else {
        return nil;
    }
}


@end
