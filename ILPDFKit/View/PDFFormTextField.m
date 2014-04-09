//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFFormTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "PDFView.h"
#import "PDF.h"

@implementation PDFFormTextField
{
    BOOL _multiline;
    
    UIView* _textFieldOrTextView;
    
    CGFloat _baseFontSize;
    CGFloat _fontSize;
    CGFloat _minFontSize;
    CGFloat _maxFontSize;
    CGFloat _fontScaleFactor;
    CGFloat _lineHeight;
    CGFloat _customTextMetricsScaleFactor;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]
    removeObserver:self];
}


-(id)initWithFrame:(CGRect)frame Multiline:(BOOL)multiline Alignment:(NSTextAlignment)alignment SecureEntry:(BOOL)secureEntry ReadOnly:(BOOL)ro
{
    self = [super initWithFrame:frame];
    if (self) {
       
        self.opaque = NO;
        self.backgroundColor = ro?[UIColor clearColor]:PDFWidgetColor;
        
        //Configure these below
        _minFontSize = 12;
        _maxFontSize = 22;
        
        _lineHeight = MIN(frame.size.height,_maxFontSize);
        
        //The scale of the font size with respect to the field height.
        _fontScaleFactor = 0.75;
        
        // Adjust this to tweak the size of the text with respect to it's bounding box.
        _customTextMetricsScaleFactor = (iPad?1.2:0.6);
        
        if(multiline == NO)
        {
            self.layer.cornerRadius = self.frame.size.height/6;
        }
        
        _multiline = multiline;
        
        Class textCls = multiline?[UITextView class]:[UITextField class];
        _textFieldOrTextView = [[textCls alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        if(secureEntry)
        {
            ((UITextField*)_textFieldOrTextView).secureTextEntry = YES;
        }
        
        if(ro)
        {
            _textFieldOrTextView.userInteractionEnabled = NO;
        }
    
        if(multiline)
        {
            ((UITextView*)_textFieldOrTextView).textAlignment = (NSTextAlignment)alignment;
            ((UITextView*)_textFieldOrTextView).autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            ((UITextView*)_textFieldOrTextView).delegate = self;
           
            ((UITextView*)_textFieldOrTextView).scrollEnabled = YES;
            [((UITextView*)_textFieldOrTextView) setTextContainerInset:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
        else 
        {
            ((UITextField*)_textFieldOrTextView).textAlignment = (NSTextAlignment)alignment;
            ((UITextField*)_textFieldOrTextView).delegate = self;
           
            ((UITextField*)_textFieldOrTextView).autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [[NSNotificationCenter defaultCenter] 
             addObserver:self 
             selector:@selector(textChanged:)
             name:UITextFieldTextDidChangeNotification 
             object:_textFieldOrTextView];
        }
       
        _textFieldOrTextView.opaque = NO;
        _textFieldOrTextView.backgroundColor = [UIColor clearColor];
        
        
        if(multiline)_baseFontSize = _minFontSize;
        else _baseFontSize = MAX(MIN(_maxFontSize,_lineHeight*_fontScaleFactor),_minFontSize);
        
        
        
        _fontSize = _baseFontSize;
        [_textFieldOrTextView performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:_baseFontSize]];
        [self addSubview:_textFieldOrTextView];
    }
    return self;
}

#pragma mark - PDFUIElement

-(void)setValue:(NSString*)value
{
    if([value isKindOfClass:[NSNull class]] == YES)
    {
        [self setValue:nil];
        return;
    }
    [_textFieldOrTextView performSelector:@selector(setText:) withObject:value];
    
   if(_multiline == NO)
   {
       UITextField* textField = (UITextField*)_textFieldOrTextView;
       CGFloat factor = [value sizeWithAttributes:@{NSFontAttributeName:textField.font}].width/(textField.bounds.size.width);
     
       {
           if(_multiline == NO)
           {
               _baseFontSize = MAX(MIN(_baseFontSize/factor,_maxFontSize),_minFontSize);
               if(_baseFontSize > _fontScaleFactor * _lineHeight)_baseFontSize = MAX(_fontScaleFactor*_lineHeight,_minFontSize);
           }
           
           
           _fontSize = _baseFontSize*_zoomScale*_customTextMetricsScaleFactor;
          
           textField.font = [UIFont systemFontOfSize:_fontSize];
       }
   }
   [self refresh];
}

-(NSString*)value
{
    NSString* ret = [_textFieldOrTextView performSelector:@selector(text)];
    return [ret length]?ret:nil;
}

-(void)updateWithZoom:(CGFloat)zoom
{
    [super updateWithZoom:zoom];
    [_textFieldOrTextView performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:_fontSize=_baseFontSize*zoom*_customTextMetricsScaleFactor]];
    [_textFieldOrTextView setNeedsDisplay];
    [self setNeedsDisplay];
}

-(void)refresh
{
    [self setNeedsDisplay];
    [_textFieldOrTextView setNeedsDisplay];
}

-(void)textChanged:(id)sender
{
    [self.delegate widgetAnnotationValueChanged:self];
}


#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView*)textView
{
    [self.delegate widgetAnnotationEntered:self];
    self.parentView.activeWidgetAnnotationView = self;
}

-(void)textViewDidEndEditing:(UITextView*)textView{
  
    self.parentView.activeWidgetAnnotationView = nil;
}

-(void)textViewDidChange:(UITextView*)textView
{
    [self.delegate widgetAnnotationValueChanged:self];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    CGSize contentSize = CGSizeMake(textView.bounds.size.width-12, CGFLOAT_MAX);
    float numLines = ceilf((textView.bounds.size.height / textView.font.lineHeight));
    NSString* newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if([newString length] < [textView.text length])return YES;
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
   
    
    CGRect textRect = [newString boundingRectWithSize:contentSize
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName:textView.font,NSParagraphStyleAttributeName:paragraphStyle}
                                        context:nil];
    
    float usedLines = ceilf(textRect.size.height/textView.font.lineHeight);
    
   

    if(usedLines >= numLines && usedLines > 1)return NO;
    return YES;
}

#pragma mark - UITextFieldDelegate


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([newString length] <= [textField.text length])return YES;
    if([newString sizeWithAttributes:@{NSFontAttributeName:textField.font}].width > (textField.bounds.size.width))
    {
        if(_baseFontSize > _minFontSize)
        {
            _baseFontSize = _minFontSize;
            _fontSize = _baseFontSize*_zoomScale;
            textField.font = [UIFont systemFontOfSize:_fontSize];
            if([newString sizeWithAttributes:@{NSFontAttributeName:textField.font}].width > (textField.bounds.size.width))return NO;
        }
        else return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.delegate widgetAnnotationEntered:self];
     self.parentView.activeWidgetAnnotationView = self;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.parentView.activeWidgetAnnotationView = nil;
}

-(void)resign
{
    [_textFieldOrTextView resignFirstResponder];
}


@end
