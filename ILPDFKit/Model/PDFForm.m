// PDFForm.m
//
// Copyright (c) 2015 Iwe Labs
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

#import "PDFForm.h"
#import "PDFFormButtonField.h"
#import "PDFFormTextField.h"
#import "PDFFormChoiceField.h"
#import "PDFFormContainer.h"
#import "PDFFormSignatureField.h"
#import "PDFViewController.h"
#import "PDFDictionary.h"
#import "PDFPage.h"
#import "PDFUtility.h"
#import "PDFArray.h"
#import "PDFString.h"
#import "PDFStream.h"
#import "PDFDocument.h"
#import "PDF.h"

@interface PDFForm(Private)
- (id)getAttributeFromLeaf:(PDFDictionary *)leaf name:(NSString *)nme inheritable:(BOOL)inheritable;
- (NSString *)getFormNameFromLeaf:(PDFDictionary *)leaf;
- (NSMutableDictionary *)getActionsFromLeaf:(PDFDictionary *)leaf;
- (NSString *)getExportValueFrom:(PDFDictionary *)leaf;
- (NSString *)getSetAppearanceStreamFromLeaf:(PDFDictionary *)leaf;
- (void)updateFlagsString;
@end

@implementation PDFForm {
    NSUInteger _flags;
    NSUInteger _annotFlags;
    PDFWidgetAnnotationView *_formUIElement;
}

#pragma mark - NSObject

- (void)dealloc {
    [self removeObservers];
    self.dictionary = nil;
    self.value = nil;
    self.options = nil;
    self.name = nil;
    self.uname = nil;
    self.actions = nil;
    self.exportValue = nil;
    self.defaultValue = nil;
    self.setAppearanceStream = nil;
    self.rawRect = nil;
    self.flagsString = nil;
}

#pragma mark - PDFForm
#pragma mark - Initialization

- (instancetype)initWithFieldDictionary:(PDFDictionary *)leaf page:(PDFPage *)pg parent:(PDFFormContainer *)p {
    self = [super init];
    if (self != nil) {
        self.dictionary = leaf;
        _value = [self getAttributeFromLeaf:leaf name:@"V" inheritable:YES];
        self.name = [self getFormNameFromLeaf:leaf];
        NSString* formTypeString = [self getAttributeFromLeaf:leaf name:@"FT"  inheritable:YES];
        self.defaultValue = [self getAttributeFromLeaf:leaf name:@"DV"  inheritable:YES];
        self.uname = [self getAttributeFromLeaf:leaf name:@"TU"  inheritable:YES];
        _flags = [[self getAttributeFromLeaf:leaf name:@"Ff"  inheritable:YES] unsignedIntegerValue];
        NSNumber *formTextAlignment = [self getAttributeFromLeaf:leaf name:@"Q" inheritable:YES];
        self.actions = [self getActionsFromLeaf:leaf];
        self.exportValue = [self getExportValueFrom:leaf];
        self.setAppearanceStream = [self getSetAppearanceStreamFromLeaf:leaf];
        PDFArray *arr = [self getAttributeFromLeaf:leaf name:@"Opt" inheritable:YES];
        NSMutableArray *temp = [NSMutableArray array];
        for (id obj in arr) {
            if ([obj isKindOfClass:[PDFArray class]]) {
                [temp addObject:[obj[0] textString]?:@""];
            } else {
                [temp addObject:[obj textString]?:@""];
            }
        }
        self.options = [NSArray arrayWithArray:temp];
        
        if ([formTypeString isEqualToString:@"Btn"]) {
            self.formType = PDFFormTypeButton;
        } else if([formTypeString isEqualToString:@"Tx"]) {
            self.formType = PDFFormTypeText;
        } else if([formTypeString isEqualToString:@"Ch"]) {
            self.formType = PDFFormTypeChoice;
        } else if([formTypeString isEqualToString:@"Sig"]) {
            self.formType = PDFFormTypeSignature;
        }
        
        NSMutableArray *tempRect = [NSMutableArray array];
        for (NSNumber *num in leaf[@"Rect"]) [tempRect addObject:num];
        self.rawRect = [NSArray arrayWithArray:tempRect];
        self.frame = [[(PDFArray *)(leaf[@"Rect"]) rect] CGRectValue];
        self.page = pg.pageNumber;
        self.mediaBox = pg.mediaBox;
        self.cropBox =  pg.cropBox;
        if (leaf[@"F"]) {
            _annotFlags = [leaf[@"F"] unsignedIntegerValue];
        }
        if (formTextAlignment) {
            self.textAlignment = [formTextAlignment unsignedIntegerValue];
        }
        [self updateFlagsString];
        self.parent = p;
        {
            BOOL noRotate = [_flagsString rangeOfString:@"NoRotate"].location!=NSNotFound;
            NSUInteger rotation = [(PDFPage *)(self.parent.document.pages[_page-1]) rotationAngle];
            if (noRotate)rotation = 0;
            CGFloat a = self.frame.size.width;
            CGFloat b = self.frame.size.height;
            CGFloat fx = self.frame.origin.x;
            CGFloat fy = self.frame.origin.y;
            CGFloat tw = self.cropBox.size.width;
            CGFloat th = self.cropBox.size.height;

            switch(rotation%360) {
                case 0:
                    break;
                case 90:
                    self.frame = CGRectMake(fy,th-fx-a, b, a);
                    break;
                case 180:
                    self.frame = CGRectMake(tw-fx-a, th-fy-b, a, b);
                    break;
                case 270:
                    self.frame = CGRectMake(tw-fy-b,fx, b, a);
                default:
                    break;
            }
        }
    }
    
    return self;
}


#pragma mark - Getters/Setters

- (void)setOptions:(NSArray *)opt {
    if ([opt isKindOfClass:[NSNull class]]) {
        self.options = nil;
        return;
    }
    _options = nil;
    _options = opt;
}


- (void)setValue:(NSString *)val {
    if ([val isKindOfClass:[NSNull class]]) {
        [self setValue:nil];
        return;
    }
    if (![val isEqualToString:_value] && (val||_value)) {
        self.modified = YES;
    }
    if (_value != val) {
        _value = nil;;
        _value = val;
    }
}


#pragma mark - Flags


- (void)updateFlagsString {
    NSString *temp = @"";
    
    if (BIT(0, _flags)) {
        temp = [temp stringByAppendingString:@"-ReadOnly"];
    }
    if (BIT(1, _flags)) {
        temp = [temp stringByAppendingString:@"-Required"];
    }
    if (BIT(2, _flags)) {
        temp = [temp stringByAppendingString:@"-NoExport"];
    }
    if (_formType == PDFFormTypeButton) {
    
        if (BIT(14, _flags)) {
            temp = [temp stringByAppendingString:@"-NoToggleToOff"];
        }
        if (BIT(15, _flags)) {
            temp = [temp stringByAppendingString:@"-Radio"];
        }
        if (BIT(16, _flags)) {
            temp = [temp stringByAppendingString:@"-Pushbutton"];
        }
    } else if (_formType == PDFFormTypeChoice) {
        if (BIT(17, _flags)) {
            temp = [temp stringByAppendingString:@"-Combo"];
        }
        if (BIT(18, _flags)) {
            temp = [temp stringByAppendingString:@"-Edit"];
        }
        if (BIT(19, _flags)) {
            temp = [temp stringByAppendingString:@"-Sort"];
        }             
    } else if(_formType == PDFFormTypeText) {
        if (BIT(12, _flags)) {
            temp = [temp stringByAppendingString:@"-Multiline"];
        } if(BIT(13, _flags)) {
            temp = [temp stringByAppendingString:@"-Password"];
        }
    }

    if (BIT(0, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-Invisible"];
    }
    if (BIT(1, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-Hidden"];
    }
    if (BIT(2, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-Print"];
    }
    if (BIT(3, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-NoZoom"];
    }
    if (BIT(4, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-NoRotate"];
    }
    if (BIT(5, _annotFlags)) {
        temp = [temp stringByAppendingString:@"-NoView"];
    }
    self.flagsString = temp;
}


#pragma mark - Resetting Forms

- (void)reset {
    self.value = self.defaultValue;
}


#pragma mark - Rendering

- (void)vectorRenderInPDFContext:(CGContextRef)ctx forRect:(CGRect)rect {
    if (self.formType == PDFFormTypeText || self.formType == PDFFormTypeChoice) {
        NSString *text = self.value;
        UIFont *font = nil;
        if (BIT(12, _flags) && self.formType == PDFFormTypeText) {
            font = [UIFont systemFontOfSize:12];
        } else font = [UIFont systemFontOfSize:rect.size.height];
        UIGraphicsPushContext(ctx);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = self.textAlignment;
        [text drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height*2.0) withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName: paragraphStyle}];
        UIGraphicsPopContext();
    } else if (self.formType == PDFFormTypeButton) {
        CGFloat minDim = MIN(rect.size.width,rect.size.height)*0.85;
        CGPoint center = CGPointMake(rect.size.width/2,rect.size.height/2);
        rect = CGRectMake(center.x-minDim/2, center.y-minDim/2, minDim, minDim);
        
        if ([self.value isEqualToString:self.exportValue]) {
            CGContextSaveGState(ctx);
            CGFloat margin = minDim/3;
            if (BIT(15, _flags)) {
                CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
                CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
                CGContextAddEllipseInRect(ctx, CGRectMake(margin, margin, rect.size.width-2*margin, rect.size.height-2*margin));
                CGContextFillPath(ctx);
            } else if (!BIT(16, _flags)) {
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
}

- (PDFWidgetAnnotationView *)createWidgetAnnotationViewForSuperviewWithWidth:(CGFloat)vwidth xMargin:(CGFloat)xmargin yMargin:(CGFloat)ymargin {
    if ([_flagsString rangeOfString:@"Hidden"].location != NSNotFound)return nil;
    if ([_flagsString rangeOfString:@"Invisible"].location != NSNotFound)return nil;
    if ([_flagsString rangeOfString:@"NoView"].location != NSNotFound)return nil;
    CGFloat width = _cropBox.size.width;
    CGFloat maxWidth = width;
    for (PDFPage *pg in self.parent.document.pages) {
        if([pg cropBox].size.width > maxWidth) maxWidth = [pg cropBox].size.width;
    }
    /*
     vwidth-2*xmargin = pixel width of canvas on screen for full screen scaled page
     xmargin = pixel width of grey border between canvas and edge of UIWebView for full scaled page.
     maxWidth = PDF canvas points of widest page;
     ((vwidth-2*xmargin)/maxWidth) = converstion factor from canvas space to device space.
     Thus hmargin is the horizonal pixel margin from the border of the screen to the beginning of the page canvas.
     */
    CGFloat hmargin = ((maxWidth-width)/2)*((vwidth-2*xmargin)/maxWidth)+xmargin;
    CGFloat height = _cropBox.size.height;
    CGRect correctedFrame = CGRectMake(_frame.origin.x-_cropBox.origin.x, height-_frame.origin.y-_frame.size.height-_cropBox.origin.y, _frame.size.width, _frame.size.height);
    CGFloat realWidth = vwidth-2*hmargin;
    CGFloat factor = realWidth/width;
    CGFloat pageOffset = 0;
    for (NSUInteger c = 0; c < self.page-1; c++) {
        PDFPage *pg = self.parent.document.pages[c];
        CGFloat iwidth = [pg cropBox].size.width;
        CGFloat ihmargin = ((maxWidth-iwidth)/2)*((vwidth-2*xmargin)/maxWidth)+xmargin;
        CGFloat iheight = [pg cropBox].size.height;
        CGFloat irealWidth = vwidth-2*ihmargin;
        CGFloat ifactor = irealWidth/iwidth;
        pageOffset+= iheight*ifactor+ymargin;
    }
    _pageFrame =  CGRectIntegral(CGRectMake(correctedFrame.origin.x*factor+hmargin, correctedFrame.origin.y*factor+ymargin, correctedFrame.size.width*factor, correctedFrame.size.height*factor));
    if (_formUIElement) {
        _formUIElement = nil;
    }
    
     _uiBaseFrame = CGRectIntegral(CGRectMake(_pageFrame.origin.x, _pageFrame.origin.y+pageOffset, _pageFrame.size.width, _pageFrame.size.height));
    switch (_formType) {
        case PDFFormTypeText: {
            PDFFormTextField *temp = [[PDFFormTextField alloc] initWithFrame:_uiBaseFrame multiline:([_flagsString rangeOfString:@"-Multiline"].location != NSNotFound) alignment:_textAlignment secureEntry:([_flagsString rangeOfString:@"-Password"].location != NSNotFound) readOnly:([_flagsString rangeOfString:@"-ReadOnly"].location != NSNotFound)];
            _formUIElement = temp;
        }
        break;
        case PDFFormTypeButton: {
            BOOL radio = ([_flagsString rangeOfString:@"-Radio"].location != NSNotFound);
            if (_setAppearanceStream) {
                if([_setAppearanceStream rangeOfString:@"ZaDb"].location!=NSNotFound && [_setAppearanceStream rangeOfString:@"(l)"].location!=NSNotFound)radio = YES;
            }
            PDFFormButtonField *temp = [[PDFFormButtonField alloc] initWithFrame:_uiBaseFrame radio:radio];
            temp.noOff = ([_flagsString rangeOfString:@"-NoToggleToOff"].location != NSNotFound);
            temp.name = self.name;
            temp.pushButton = ([_flagsString rangeOfString:@"Pushbutton"].location != NSNotFound);
            temp.exportValue = self.exportValue;
            _formUIElement = temp;
        }
        break;
        case PDFFormTypeChoice: {
            PDFFormChoiceField *temp = [[PDFFormChoiceField alloc] initWithFrame:_uiBaseFrame options:_options];
            _formUIElement = temp;
        }
        break;
        case PDFFormTypeSignature: {
            PDFFormSignatureField *temp = [[PDFFormSignatureField alloc] initWithFrame:_uiBaseFrame];
            _formUIElement = temp;
        }
        break;
        case PDFFormTypeNone:
        default:
            break;
    }
    if (_formUIElement) {
        [_formUIElement setValue:self.value];
        _formUIElement.delegate = self;
        [self addObserver:_formUIElement forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:_formUIElement forKeyPath:@"options" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _formUIElement;
}


#pragma mark - PDFWidgetAnnotationViewDelegate

- (void)widgetAnnotationEntered:(PDFWidgetAnnotationView *)sender {
}

- (void)widgetAnnotationValueChanged:(PDFWidgetAnnotationView *)sender {
    
    self.modified = YES;
    PDFWidgetAnnotationView *v = ((PDFWidgetAnnotationView *)sender);
    if ([v isKindOfClass:[PDFFormButtonField class]]) {
        PDFFormButtonField *button =  (PDFFormButtonField *)v;
        BOOL set = [button.exportValue isEqualToString:button.value];
        if (!button.pushButton) {
            if (button.noOff && set) {
                return;
            } else {
                [_parent setValue:set?nil:_exportValue forFormWithName:self.name];
            }
        } else {
            self.modified = NO;
            return;
        }
    } else {
        [_parent setValue:[v value] forFormWithName:self.name];
    }
}

- (void)widgetAnnotationOptionsChanged:(PDFWidgetAnnotationView *)sender {
    self.options = ((PDFWidgetAnnotationView *)sender).options;
}

#pragma mark - Private

- (id)getAttributeFromLeaf:(PDFDictionary *)leaf name:(NSString *)nme  inheritable:(BOOL)inheritable {
    PDFDictionary *iter = nil;
    PDFDictionary *temp = nil;
    id object;
    temp = leaf[@"Parent"];
    iter = ((temp == nil) ? leaf.parent : leaf);temp = nil;
    if (iter == nil) iter = leaf;
    BOOL objectIsValid;
    while (!(objectIsValid = ((object = iter[nme]) != nil)) && inheritable) {
        object = nil;
        if (!(temp = iter[@"Parent"])) break;
        iter = temp;
    }
    if ((!inheritable && !objectIsValid) || object == NULL) return nil;
    if ([object isKindOfClass:PDFString.class]) object = [object textString];
    return object;
}


- (NSString *)getFormNameFromLeaf:(PDFDictionary *)leaf {
    PDFDictionary *iter = nil;
    PDFDictionary *temp = nil;
    temp = leaf[@"Parent"];
    iter = ((temp == nil) ? leaf.parent : leaf);temp = nil;
    if (iter == nil) iter = leaf;
    PDFString *string = nil;
    NSString *ret = @"";
    do {
        BOOL objectIsValid = [(string = iter[@"T"]) isKindOfClass:[PDFString class]];
        if (objectIsValid) {
            ret = [[NSString stringWithFormat:@"%@.",[string textString]] stringByAppendingString:ret];
        }
        temp = iter[@"Parent"];
        if (temp == nil) break;
        iter = temp;
        
    } while(YES);
    
    if ([ret length] > 0) ret = [ret substringToIndex:[ret length]-1];
    return ret;
}


- (NSMutableDictionary *)getActionsFromLeaf:(PDFDictionary *)leaf {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    PDFDictionary *actionsd = nil;
    if ((actionsd = leaf[@"A"]) != nil) {
        ret[@"A"] = actionsd;
    }
    PDFDictionary *iter = nil;
    PDFDictionary *temp = nil;
    temp = leaf[@"Parent"];
    iter = ((temp == nil)?leaf.parent:leaf);temp = nil;
    if (iter == nil) iter = leaf;
    
    PDFDictionary *additionalActions = nil;
    BOOL active = ((additionalActions = iter[@"AA"]) != nil);
    
    if (!active && iter!= leaf) {
        active = ((additionalActions = leaf[@"AA"]) != nil);
    }
    if (active) {
        NSArray *keys = @[@"E",@"K",@"V"];
        for (PDFName *key in keys) {
            PDFDictionary* action = nil;
            if ((action = additionalActions[key])) {
                ret[key] = action;
            }
        }
    }
    return ret;
}

- (NSString *)getSetAppearanceStreamFromLeaf:(PDFDictionary *)leaf {
    PDFDictionary *ap = nil;
    if ((ap = leaf[@"AP"])) {
        PDFDictionary *n = nil;
        if ([(n = ap[@"N"]) isKindOfClass:[PDFDictionary class]]) {
            for (PDFName *key in [n allKeys]) {
                if (![key isEqualToString:@"Off"] && ![key isEqualToString:@"OFF"]) {
                    PDFStream *str = n[key];
                    if ([str isKindOfClass:[PDFStream class]]) {
                        NSData *dat = str.data;
                        if (str.dataFormat == CGPDFDataFormatRaw) {
                            return [PDFUtility stringFromPDFData:dat];
                        }
                    }
                }
            }
        }
    }
    return nil;
}

- (NSString *)getExportValueFrom:(PDFDictionary *)leaf {
    PDFDictionary *ap = nil;
    if ((ap = leaf[@"AP"])) {
        PDFDictionary *n = nil;
        if ([(n = ap[@"N"]) isKindOfClass:[PDFDictionary class]]) {
            for (PDFName *key in [n allKeys]) {
                if(![key isEqualToString:@"Off"] && ![key isEqualToString:@"OFF"])return key;
            }
        }
    }
    id as = nil;
    if ((as = leaf[@"AS"])) {
        if ([as isKindOfClass:NSString.class]) as = [as textString];
        return as;
    }
    return nil;
}


#pragma mark - KVO

- (void)removeObservers {
    if (_formUIElement) {
        [self removeObserver:_formUIElement forKeyPath:@"value"];
        [self removeObserver:_formUIElement forKeyPath:@"options"];
        _formUIElement = nil;
    }
}

@end





