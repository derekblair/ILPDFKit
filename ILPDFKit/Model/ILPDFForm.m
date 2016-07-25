// ILPDFForm.m
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

#import <ILPDFKit/ILPDFKit.h>
#import "ILPDFFormButtonField.h"
#import "ILPDFFormTextField.h"
#import "ILPDFFormChoiceField.h"
#import "ILPDFFormSignatureField.h"
#import "ILPDFFormContainer.h"

@interface ILPDFForm(Delegates) <ILPDFWidgetAnnotationViewDelegate>
@end

@interface ILPDFForm(Private)
- (NSString *)getExportValueFrom:(ILPDFDictionary *)leaf;
- (NSString *)getSetAppearanceStreamFromLeaf:(ILPDFDictionary *)leaf;
- (void)updateFlagsString;
@end

@implementation ILPDFForm {
    NSUInteger _flags;
    NSUInteger _annotFlags;
    ILPDFWidgetAnnotationView *_formUIElement;
}

#pragma mark - NSObject

- (void)dealloc {
    [self removeObservers];
}

#pragma mark - NSObject


- (id)init {
    ILPDFDictionary *dict  = nil;
    self = [self initWithFieldDictionary:dict page:nil parent:nil];
    return self;
}


#pragma mark - ILPDFForm
#pragma mark - Initialization

- (instancetype)initWithFieldDictionary:(ILPDFDictionary *)leaf page:(ILPDFPage *)pg parent:(ILPDFFormContainer *)p {
    NSParameterAssert(leaf);
    NSParameterAssert(pg);
    NSParameterAssert(p);
    self = [super init];
    if (self != nil) {
        _dictionary = leaf;
        id value = [leaf inheritableValueForKey:@"V"];
        _value = [value isKindOfClass:ILPDFString.class] ? [value textString]:value;
        id defaultValue = [leaf inheritableValueForKey:@"DV"];
        _defaultValue = ([defaultValue isKindOfClass:ILPDFString.class]) ? [defaultValue textString]:defaultValue;
        NSMutableArray *nameComponents = [NSMutableArray array];
        for (ILPDFString *obj in [[leaf parentValuesForKey:@"T"] reverseObjectEnumerator]) [nameComponents addObject:[obj textString]];
        _name = [nameComponents componentsJoinedByString:@"."];
        NSString *formTypeString = [leaf inheritableValueForKey:@"FT"];
        _uname = [[leaf inheritableValueForKey:@"TU"] textString];
        _flags = [[leaf inheritableValueForKey:@"Ff"] unsignedIntegerValue];
        NSNumber *formTextAlignment = [leaf  inheritableValueForKey:@"Q"];
        _exportValue = [self getExportValueFrom:leaf];
        _setAppearanceStream = [self getSetAppearanceStreamFromLeaf:leaf];
        ILPDFArray *arr = [leaf inheritableValueForKey:@"Opt"];
        NSMutableArray *temp = [NSMutableArray array];
        for (id obj in arr) {
            if ([obj isKindOfClass:[ILPDFArray class]]) {
                [temp addObject:[obj[0] textString] ?: @""];
            } else {
                [temp addObject:[obj textString] ?: @""];
            }
        }
        self.options = [NSArray arrayWithArray:temp];
        
        if ([formTypeString isEqualToString:@"Btn"]) {
            _formType = ILPDFFormTypeButton;
        } else if([formTypeString isEqualToString:@"Tx"]) {
            _formType = ILPDFFormTypeText;
        } else if([formTypeString isEqualToString:@"Ch"]) {
            _formType = ILPDFFormTypeChoice;
        } else if([formTypeString isEqualToString:@"Sig"]) {
            _formType = ILPDFFormTypeSignature;
        }
        
        NSMutableArray *tempRect = [NSMutableArray array];
        for (NSNumber *num in leaf[@"Rect"]) [tempRect addObject:num];
        _rawRect = [NSArray arrayWithArray:tempRect];
        _frame = [[(ILPDFArray *)(leaf[@"Rect"]) rect] CGRectValue];
        _page = pg.pageNumber;
        _mediaBox = pg.mediaBox;
        _cropBox =  pg.cropBox;
        if (leaf[@"F"]) {
            _annotFlags = [leaf[@"F"] unsignedIntegerValue];
        }
        if (formTextAlignment) {
            _textAlignment = [formTextAlignment unsignedIntegerValue];
        }
        [self updateFlagsString];
        _parent = p;
        {
            BOOL noRotate = (_annotFlags & ILPDFAnnotationFlagNoRotate) > 0;
            NSUInteger rotation = [(ILPDFPage *)(self.parent.document.pages[_page-1]) rotationAngle];
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
                    _frame = CGRectMake(fy,th-fx-a, b, a);
                    break;
                case 180:
                    _frame = CGRectMake(tw-fx-a, th-fy-b, a, b);
                    break;
                case 270:
                    _frame = CGRectMake(tw-fy-b,fx, b, a);
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
        _modified = YES;
    }
    if (_value != val) {
        _value = nil;;
        _value = val;
    }
}


#pragma mark - Flags


- (void)updateFlagsString {
    NSString *temp = @"";
    
    if ((_flags & ILPDFFormFlagReadOnly) > 0) {
        temp = [temp stringByAppendingString:@"-ReadOnly"];
    }
    if ((_flags & ILPDFFormFlagRequired) > 0) {
        temp = [temp stringByAppendingString:@"-Required"];
    }
    if ((_flags & ILPDFFormFlagNoExport) > 0) {
        temp = [temp stringByAppendingString:@"-NoExport"];
    }
    if (_formType == ILPDFFormTypeButton) {
    
        if ((_flags & ILPDFFormFlagButtonNoToggleToOff) > 0) {
            temp = [temp stringByAppendingString:@"-NoToggleToOff"];
        }
        if ((_flags & ILPDFFormFlagButtonRadio) > 0) {
            temp = [temp stringByAppendingString:@"-Radio"];
        }
        if ((_flags & ILPDFFormFlagButtonPushButton) > 0) {
            temp = [temp stringByAppendingString:@"-Pushbutton"];
        }
    } else if (_formType == ILPDFFormTypeChoice) {
        if ((_flags & ILPDFFormFlagChoiceFieldIsCombo) > 0) {
            temp = [temp stringByAppendingString:@"-Combo"];
        }
        if ((_flags & ILPDFFormFlagChoiceFieldEditable) > 0) {
            temp = [temp stringByAppendingString:@"-Edit"];
        }
        if ((_flags & ILPDFFormFlagChoiceFieldSorted) > 0) {
            temp = [temp stringByAppendingString:@"-Sort"];
        }             
    } else if(_formType == ILPDFFormTypeText) {
        if ((_flags & ILPDFFormFlagTextFieldMultiline) > 0) {
            temp = [temp stringByAppendingString:@"-Multiline"];
        } if((_flags & ILPDFFormFlagTextFieldPassword) > 0) {
            temp = [temp stringByAppendingString:@"-Password"];
        }
    }

    if ((_annotFlags & ILPDFAnnotationFlagInvisible) > 0) {
        temp = [temp stringByAppendingString:@"-Invisible"];
    }
    if ((_annotFlags & ILPDFAnnotationFlagHidden) > 0) {
        temp = [temp stringByAppendingString:@"-Hidden"];
    }
    if ((_annotFlags & ILPDFAnnotationFlagPrint) > 0) {
        temp = [temp stringByAppendingString:@"-Print"];
    }
    if ((_annotFlags & ILPDFAnnotationFlagNoZoom) > 0) {
        temp = [temp stringByAppendingString:@"-NoZoom"];
    }
    if ((_annotFlags & ILPDFAnnotationFlagNoRotate) > 0) {
        temp = [temp stringByAppendingString:@"-NoRotate"];
    }
    if ((_annotFlags & ILPDFAnnotationFlagNoView) > 0) {
        temp = [temp stringByAppendingString:@"-NoView"];
    }
    _flagsString = temp;
}


#pragma mark - Resetting Forms

- (void)reset {
    self.value = self.defaultValue;
}

#pragma mark - Rendering

- (void)vectorRenderInPDFContext:(CGContextRef)ctx forRect:(CGRect)rect {
    if (self.formType == ILPDFFormTypeText || self.formType == ILPDFFormTypeChoice) {
        NSString *text = self.value;
        UIFont *font = [UIFont systemFontOfSize:[ILPDFWidgetAnnotationView fontSizeForRect:rect value:self.value multiline:((_flags & ILPDFFormFlagTextFieldMultiline) > 0 && self.formType == ILPDFFormTypeText) choice:self.formType == ILPDFFormTypeChoice]];
        UIGraphicsPushContext(ctx);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = self.textAlignment;
        [text drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height*2.0) withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName: paragraphStyle}];
        UIGraphicsPopContext();
    } else if (self.formType == ILPDFFormTypeButton) {
       [ILPDFFormButtonField drawWithRect:rect context:ctx back:NO selected:[self.value isEqualToString:self.exportValue] && (_flags & ILPDFFormFlagButtonPushButton) == 0 radio:(_flags & ILPDFFormFlagButtonRadio) > 0];
    }
}



- (ILPDFWidgetAnnotationView *)associatedWidget {
    return _formUIElement;
}


- (void)updateFrameForPDFPageView:(UIView *)pdfPage {


    CGFloat vwidth = pdfPage.bounds.size.width;
    CGRect correctedFrame = CGRectMake(_frame.origin.x-_cropBox.origin.x, _cropBox.size.height-_frame.origin.y-_frame.size.height-_cropBox.origin.y, _frame.size.width, _frame.size.height);
    CGFloat factor = vwidth/_cropBox.size.width;
    _pageFrame =  CGRectIntegral(CGRectMake(correctedFrame.origin.x*factor, correctedFrame.origin.y*factor, correctedFrame.size.width*factor, correctedFrame.size.height*factor));
    _uiBaseFrame = [pdfPage convertRect:_pageFrame toView:pdfPage.superview];

    _formUIElement.frame = _uiBaseFrame;
    [_formUIElement updateWithZoom:_formUIElement.zoomScale];

}

- (ILPDFWidgetAnnotationView *)createWidgetAnnotationViewForPageView:(UIView *)pageView {



    if ((_annotFlags & ILPDFAnnotationFlagHidden) > 0) return nil;
    if ((_annotFlags & ILPDFAnnotationFlagInvisible) > 0) return nil;
    if ((_annotFlags & ILPDFAnnotationFlagNoView) > 0) return nil;


    if (_formUIElement) {
        _formUIElement = nil;
    }
    [self updateFrameForPDFPageView:pageView];

    switch (_formType) {
        case ILPDFFormTypeText:
            _formUIElement = [[ILPDFFormTextField alloc] initWithFrame:_uiBaseFrame multiline:((_flags & ILPDFFormFlagTextFieldMultiline) > 0) alignment:_textAlignment secureEntry:((_flags & ILPDFFormFlagTextFieldPassword) > 0) readOnly:((_flags & ILPDFFormFlagReadOnly) > 0)];
        break;
        case ILPDFFormTypeButton: {
            BOOL radio = ((_flags & ILPDFFormFlagButtonRadio) > 0);
            if (_setAppearanceStream) {
                if ([_setAppearanceStream rangeOfString:@"ZaDb"].location != NSNotFound && [_setAppearanceStream rangeOfString:@"(l)"].location!=NSNotFound)radio = YES;
            }
            ILPDFFormButtonField *temp = [[ILPDFFormButtonField alloc] initWithFrame:_uiBaseFrame radio:radio];
            temp.noOff = ((_flags & ILPDFFormFlagButtonNoToggleToOff) > 0);
            temp.name = self.name;
            temp.pushButton = ((_flags & ILPDFFormFlagButtonPushButton) > 0);
            temp.exportValue = self.exportValue;
            _formUIElement = temp;
        }
        break;
        case ILPDFFormTypeChoice:
            _formUIElement = [[ILPDFFormChoiceField alloc] initWithFrame:_uiBaseFrame options:_options];
        break;
        case ILPDFFormTypeSignature:
            _formUIElement = [[ILPDFFormSignatureField alloc] initWithFrame:_uiBaseFrame];
        break;
        case ILPDFFormTypeNone:
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


#pragma mark - ILPDFWidgetAnnotationViewDelegate

- (void)widgetAnnotationEntered:(ILPDFWidgetAnnotationView *)sender {
}

- (void)widgetAnnotationValueChanged:(ILPDFWidgetAnnotationView *)sender {
    _modified = YES;
    ILPDFWidgetAnnotationView *v = ((ILPDFWidgetAnnotationView *)sender);
    if ([v isKindOfClass:[ILPDFFormButtonField class]]) {
        ILPDFFormButtonField *button =  (ILPDFFormButtonField *)v;
        BOOL set = [button.exportValue isEqualToString:button.value];
        if (!button.pushButton) {
            if (button.noOff && set) {
                return;
            } else {
                [_parent setValue:(set ? nil:_exportValue) forFormWithName:self.name];
            }
        } else {
            _modified = NO;
            return;
        }
    } else {
        [_parent setValue:[v value] forFormWithName:self.name];
    }
}

- (void)widgetAnnotationOptionsChanged:(ILPDFWidgetAnnotationView *)sender {
    self.options = ((ILPDFWidgetAnnotationView *)sender).options;
}

#pragma mark - Private

- (NSString *)getSetAppearanceStreamFromLeaf:(ILPDFDictionary *)leaf {
    ILPDFDictionary *ap = nil;
    if ((ap = leaf[@"AP"])) {
        ILPDFDictionary *n = nil;
        if ([(n = ap[@"N"]) isKindOfClass:[ILPDFDictionary class]]) {
            for (ILPDFName *key in [n allKeys]) {
                if (![key isEqualToString:@"Off"] && ![key isEqualToString:@"OFF"]) {
                    ILPDFStream *str = n[key];
                    if ([str isKindOfClass:[ILPDFStream class]]) {
                        NSData *dat = str.data;
                        if (str.dataFormat == CGPDFDataFormatRaw) {
                            return [ILPDFUtility stringFromPDFData:dat];
                        }
                    }
                }
            }
        }
    }
    return nil;
}

- (NSString *)getExportValueFrom:(ILPDFDictionary *)leaf {
    ILPDFDictionary *ap = nil;
    if ((ap = leaf[@"AP"])) {
        ILPDFDictionary *n = nil;
        if ([(n = ap[@"N"]) isKindOfClass:[ILPDFDictionary class]]) {
            for (ILPDFName *key in [n allKeys]) {
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





