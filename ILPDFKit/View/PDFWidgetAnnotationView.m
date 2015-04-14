// PDFWidgetAnnotationView.m
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

#import "PDF.h"
#import "PDFWidgetAnnotationView.h"

#define PDFTextFieldFontScaleFactor 0.75
#define PDFChoiceFieldBaseFontSizeToFrameHeightScaleFactor 0.8

@implementation PDFWidgetAnnotationView

#pragma mark - NSObject

- (void)dealloc {
    if (_parentView.activeWidgetAnnotationView == self) {
        [self resign];
        _parentView.activeWidgetAnnotationView = nil;
    }
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _baseFrame = frame;
        _zoomScale = 1.0;
    }
    return self;
}


#pragma mark - PDFWidgetAnnotationView

- (void)updateWithZoom:(CGFloat)zoom {
    _zoomScale = zoom;
    self.frame = CGRectMake(_baseFrame.origin.x*zoom,_baseFrame.origin.y*zoom,_baseFrame.size.width*zoom,_baseFrame.size.height*zoom);
}

+ (CGFloat)fontSizeForRect:(CGRect)rect value:(NSString *)value multiline:(BOOL)multiline choice:(BOOL)choice {
    if (multiline) return PDFFormMinFontSize;
    CGFloat baseSize;
    if (choice) baseSize = roundf(MIN(MAX(floorf(rect.size.height*PDFChoiceFieldBaseFontSizeToFrameHeightScaleFactor),PDFFormMinFontSize),PDFFormMaxFontSize));
    else baseSize = roundf(MAX(MIN(PDFFormMaxFontSize,MIN(rect.size.height, PDFFormMaxFontSize)*PDFTextFieldFontScaleFactor),PDFFormMinFontSize));
    if (value) {
        while (baseSize >= PDFFormMinFontSize && [value sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:baseSize]}].width > rect.size.width-PDFFormMinFontSize) {
            baseSize -= 1.0;
        }
        return baseSize;
    } else return baseSize;
}

- (void)setValue:(NSString *)value {
}

- (NSString *)value {
    return nil;
}

- (void)setOptions:(NSArray *)options {
}

- (NSArray *)options {
    return nil;
}

- (void)refresh {
    [self setNeedsDisplay];
}

- (void)resign {
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"value"]) {
        self.value = change[NSKeyValueChangeNewKey];
    } else if ([keyPath isEqualToString:@"options"]) {
        self.options = change[NSKeyValueChangeNewKey];
    }
}

@end
