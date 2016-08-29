// ILPDFFormContainer.m
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
#import "ILPDFFormContainer.h"
#import "ILPDFFormChoiceField.h"
#import "ILPDFFormButtonField.h"
#import "ILPDFView.h"

@interface ILPDFFormContainer(Private)
- (void)populateNameTreeNode:(NSMutableDictionary *)node withComponents:(NSArray *)components final:(ILPDFForm *)final;
- (NSArray *)formsDescendingFromTreeNode:(NSDictionary *)node;
- (void)applyAnnotationTypeLeafToForms:(ILPDFDictionary *)leaf parent:(ILPDFDictionary *)parent pageMap:(NSDictionary *)pmap;
- (void)enumerateFields:(ILPDFDictionary *)fieldDict pageMap:(NSDictionary *)pmap;
- (NSArray *)allForms;
- (NSString *)formXMLForFormsWithRootNode:(NSDictionary *)node;
- (void)addForm:(ILPDFForm *)form;
- (void)removeForm:(ILPDFForm *)form;
@end

@implementation ILPDFFormContainer {
    NSMutableArray *_allForms;
    NSMutableDictionary *_nameTree;
}

#pragma mark - NSObject.


- (id)init {
    ILPDFDocument *doc = nil;
    self = [self initWithParentDocument:doc];
    return self;
}

#pragma mark - Initialization

- (instancetype)initWithParentDocument:(ILPDFDocument *)parent {
    NSParameterAssert(parent);
    self = [super init];
    if (self != nil) {
        _allForms = [[NSMutableArray alloc] init];
        _nameTree = [[NSMutableDictionary alloc] init];
        _document = parent;
        NSMutableDictionary *pmap = [NSMutableDictionary dictionary];
        for (ILPDFPage *page in _document.pages) {
            pmap[@((NSUInteger)(page.dictionary.dict))] = @(page.pageNumber);
        }
        for (ILPDFDictionary *field in _document.catalog[@"AcroForm"][@"Fields"]) {
            [self enumerateFields:field pageMap:pmap];
        }
    }
    return self;
}


#pragma mark - Getting Forms

- (NSArray *)formsWithName:(NSString *)name {
    id current = _nameTree;
    NSArray *comps = [name componentsSeparatedByString:@"."];
    for (NSString *comp in comps) {
        current = current[comp];
        if (current == nil)return nil;
        if ([current isKindOfClass:[NSMutableArray class]]) {
            if (comp == [comps lastObject])
                return current;
            else
                return nil;
        }
    }
    return [self formsDescendingFromTreeNode:current];
}


- (NSArray *)formsWithType:(ILPDFFormType)type {
    NSMutableArray *temp = [NSMutableArray array];
    for (ILPDFForm *form in [self allForms]) {
        if (form.formType == type) {
            [temp addObject:form];
        }
    }
    return [NSArray arrayWithArray:temp];
}

- (NSArray *)allForms {
    return _allForms;
}

#pragma mark - Adding and Removing Forms

- (void)addForm:(ILPDFForm *)form {
    [_allForms addObject:form];
    [self populateNameTreeNode:_nameTree withComponents:[form.name componentsSeparatedByString:@"."] final:form];
}

- (void)removeForm:(ILPDFForm *)form {
    [_allForms removeObject:form];
    id current = _nameTree;
    NSArray *comps = [form.name componentsSeparatedByString:@"."];
    for (NSString *comp in comps) {
        current = current[comp];
    }
    [current removeObject:form];
}


#pragma mark - Private

- (void)enumerateFields:(ILPDFDictionary *)fieldDict pageMap:(NSDictionary *)pmap {
    if (fieldDict[@"Subtype"]) {
        ILPDFDictionary *parent = fieldDict.parent;
        [self applyAnnotationTypeLeafToForms:fieldDict parent:parent pageMap:pmap];
    } else {
        for (ILPDFDictionary *innerFieldDictionary in fieldDict[@"Kids"]) {
            ILPDFDictionary *parent = innerFieldDictionary.parent;
            if (parent != nil) [self enumerateFields:innerFieldDictionary pageMap:pmap];
            else [self applyAnnotationTypeLeafToForms:innerFieldDictionary parent:fieldDict pageMap:pmap];
        }
    }
}

- (void)applyAnnotationTypeLeafToForms:(ILPDFDictionary *)leaf parent:(ILPDFDictionary *)parent pageMap:(NSDictionary *)pmap {
    NSUInteger targ = (NSUInteger)(((ILPDFDictionary *)(leaf[@"P"])).dict);
    leaf.parent = parent;
    NSUInteger index = targ ? ([pmap[@(targ)] unsignedIntegerValue] - 1):0;
    ILPDFForm *form = [[ILPDFForm alloc] initWithFieldDictionary:leaf page:_document.pages[index] parent:self];
    [self addForm:form];
}

-(NSArray *)formsDescendingFromTreeNode:(NSDictionary *)node {
    NSMutableArray *ret = [NSMutableArray array];
    for (NSString *key in [node allKeys]) {
        id obj = node[key];
        if ([obj isKindOfClass:[NSMutableArray class]]) {
            [ret addObjectsFromArray:obj];
        } else {
            [ret addObjectsFromArray:[self formsDescendingFromTreeNode:obj]];
        }
    }
    return ret;
}


- (void)populateNameTreeNode:(NSMutableDictionary *)node withComponents:(NSArray *)components final:(ILPDFForm *)final {
    NSString *base = components[0];
    if ([components count] == 1) {
        NSMutableArray *arr = node[base];
        if (arr == nil) {
            arr = [NSMutableArray arrayWithObject:final];
            node[base] = arr;
        } else {
            [arr addObject:final];
        }
        return;
    }
    NSMutableDictionary *dict  = node[base];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
        node[base] = dict;
    }
    [self populateNameTreeNode:dict withComponents:[components subarrayWithRange:NSMakeRange(1, [components count]-1)] final:final];
}

#pragma mark - Form Value Setting

- (void)setValue:(NSString *)val forFormWithName:(NSString *)name {
    for (ILPDFForm *form in [self formsWithName:name]) {
        if (((![form.value isEqualToString:val]) && (form.value != nil || val != nil))) {
            form.value = val;
        }
    }
}

#pragma mark - formXML

- (NSString *)formXML {
    NSMutableString *ret = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r<fields>"];
    [ret appendString:[self formXMLForFormsWithRootNode:_nameTree]];
    [ret appendString:@"\r</fields>"];
    return [[[ret stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"] stringByReplacingOccurrencesOfString:@"&amp;#60;" withString:@"&#60;"] stringByReplacingOccurrencesOfString:@"&amp;#62;" withString:@"&#62;"];
}


- (NSString *)formXMLForFormsWithRootNode:(NSDictionary *)node {
    NSMutableString *ret = [NSMutableString string];
    for (NSString *key in [node allKeys]) {
        id obj = node[key];
        if ([obj isKindOfClass:[NSMutableArray class]]) {
            ILPDFForm *form = (ILPDFForm *)[obj lastObject];
            if ([form.value length])[ret appendFormat:@"\r<%@>%@</%@>",key,[ILPDFUtility encodeStringForXML: form.value],key];
        } else {
            NSString *val = [self formXMLForFormsWithRootNode:obj];
            if ([val length])[ret appendFormat:@"\r<%@>%@</%@>",key,val,key];
        }
    }
    return ret;
}


#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [[self allForms] countByEnumeratingWithState:state objects:buffer count:len];
}

- (void)updateWidgetAnnotationViews:(NSMapTable *)pageViews views:(NSMutableArray *)views pdfView:(ILPDFView *)pdfView  {

    BOOL wasAdded = NO;

    for (ILPDFForm *form in self) {
        UIView *pageView = (UIView *)[pageViews objectForKey: @(form.page)];
        if (pageView == nil) continue;

        ILPDFWidgetAnnotationView *add = nil;
        if ([form associatedWidget] == nil) {
            add = [form createWidgetAnnotationViewForPageView:pageView ];
            add.page = form.page;
            wasAdded = YES;
            [views addObject:add];
        } else {
            add = [form associatedWidget];
        }

        if (add.superview == nil && ![add isKindOfClass:[ILPDFFormChoiceField class]]) {
            [pdfView.pdfView.scrollView addSubview:add];
            add.parentView = pdfView;
            if ([add isKindOfClass:[ILPDFFormButtonField class]]) {
                [(ILPDFFormButtonField *)add setButtonSuperview];
            }
        }
    }

    if (wasAdded) {
        [views sortUsingComparator:^NSComparisonResult(ILPDFWidgetAnnotationView *obj1, ILPDFWidgetAnnotationView *obj2) {
            if ( obj1.baseFrame.origin.y > obj2.baseFrame.origin.y) return NSOrderedAscending;
            else return NSOrderedDescending;
        }];

        for (UIView *v in views) {
            if ([v isKindOfClass:[ILPDFFormChoiceField class]]) {
                [pdfView.pdfView.scrollView addSubview:v];
                ((ILPDFFormChoiceField *)v).parentView = pdfView;
            }
        }
    }

     for (ILPDFForm *form in self) {
         UIView *pageView = (UIView *)[pageViews objectForKey: @(form.page)];
         if (pageView == nil) continue;
         [form updateFrameForPDFPageView:pageView];
     }
}

@end






