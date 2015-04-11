// PDFFormContainer.m
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
#import "PDFFormContainer.h"

@interface PDFFormContainer(Private)
- (void)populateNameTreeNode:(NSMutableDictionary *)node withComponents:(NSArray *)components final:(PDFForm *)final;
- (NSArray *)formsDescendingFromTreeNode:(NSDictionary *)node;
- (void)applyAnnotationTypeLeafToForms:(PDFDictionary *)leaf parent:(PDFDictionary *)parent pageMap:(NSDictionary *)pmap;
- (void)enumerateFields:(PDFDictionary *)fieldDict pageMap:(NSDictionary *)pmap;
- (NSArray *)allForms;
- (NSString *)formXMLForFormsWithRootNode:(NSDictionary *)node;
- (void)addForm:(PDFForm *)form;
- (void)removeForm:(PDFForm *)form;
@end

@implementation PDFFormContainer {
    NSMutableArray *_allForms;
    NSMutableDictionary *_nameTree;
}


#pragma mark - Initialization

- (instancetype)initWithParentDocument:(PDFDocument *)parent {
    self = [super init];
    if (self != nil) {
        _allForms = [[NSMutableArray alloc] init];
        _nameTree = [[NSMutableDictionary alloc] init];
        _document = parent;
        NSMutableDictionary *pmap = [NSMutableDictionary dictionary];
        for (PDFPage *page in _document.pages) {
            pmap[@((NSUInteger)(page.dictionary.dict))] = @(page.pageNumber);
        }
        for (PDFDictionary *field in _document.catalog[@"AcroForm"][@"Fields"]) {
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


- (NSArray *)formsWithType:(PDFFormType)type {
    NSMutableArray *temp = [NSMutableArray array];
    for (PDFForm *form in [self allForms]) {
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

- (void)addForm:(PDFForm *)form {
    [_allForms addObject:form];
    [self populateNameTreeNode:_nameTree withComponents:[form.name componentsSeparatedByString:@"."] final:form];
}

- (void)removeForm:(PDFForm *)form {
    [_allForms removeObject:form];
    id current = _nameTree;
    NSArray *comps = [form.name componentsSeparatedByString:@"."];
    for (NSString *comp in comps) {
        current = current[comp];
    }
    [current removeObject:form];
}


#pragma mark - Private

- (void)enumerateFields:(PDFDictionary *)fieldDict pageMap:(NSDictionary *)pmap {
    if (fieldDict[@"Subtype"]) {
        PDFDictionary *parent = fieldDict.parent;
        [self applyAnnotationTypeLeafToForms:fieldDict parent:parent pageMap:pmap];
    } else {
        for (PDFDictionary *innerFieldDictionary in fieldDict[@"Kids"]) {
            PDFDictionary *parent = innerFieldDictionary.parent;
            if (parent != nil) [self enumerateFields:innerFieldDictionary pageMap:pmap];
            else [self applyAnnotationTypeLeafToForms:innerFieldDictionary parent:fieldDict pageMap:pmap];
        }
    }
}

- (void)applyAnnotationTypeLeafToForms:(PDFDictionary *)leaf parent:(PDFDictionary *)parent pageMap:(NSDictionary *)pmap {
    NSUInteger targ = (NSUInteger)(((PDFDictionary *)(leaf[@"P"])).dict);
    leaf.parent = parent;
    NSUInteger index = targ ? ([pmap[@(targ)] unsignedIntegerValue] - 1):0;
    PDFForm *form = [[PDFForm alloc] initWithFieldDictionary:leaf page:_document.pages[index] parent:self];
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


- (void)populateNameTreeNode:(NSMutableDictionary *)node withComponents:(NSArray *)components final:(PDFForm *)final {
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
    for (PDFForm *form in [self formsWithName:name]) {
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
            PDFForm *form = (PDFForm *)[obj lastObject];
            if ([form.value length])[ret appendFormat:@"\r<%@>%@</%@>",key,[PDFUtility encodeStringForXML: form.value],key];
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


- (NSArray *)createWidgetAnnotationViewsForSuperviewWithWidth:(CGFloat)width margin:(CGFloat)margin hMargin:(CGFloat)hmargin {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (PDFForm *form in self) {
        if (form.formType == PDFFormTypeChoice) continue;
        id add = [form createWidgetAnnotationViewForSuperviewWithWidth:width xMargin:margin yMargin:hmargin];
        if (add) [ret addObject:add];
    }
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    //We keep choice fileds on top.
    for (PDFForm *form in [self formsWithType:PDFFormTypeChoice]) {
        id add = [form createWidgetAnnotationViewForSuperviewWithWidth:width xMargin:margin yMargin:hmargin];
        if(add) [temp addObject:add];
    }
    [temp sortUsingComparator:^NSComparisonResult(PDFWidgetAnnotationView *obj1, PDFWidgetAnnotationView *obj2) {
        if( obj1.baseFrame.origin.y > obj2.baseFrame.origin.y)return NSOrderedAscending;
        return NSOrderedDescending;
    }];
    [ret addObjectsFromArray:temp];
    return ret;
}

@end






