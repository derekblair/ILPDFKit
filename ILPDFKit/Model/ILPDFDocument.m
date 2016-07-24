// ILPDFDocument.m
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

#import "ILPDFFormButtonField.h"
#import "ILPDFFormContainer.h"
#import "ILPDFSerializer.h"
#import <ILPDFKit/ILPDFKit.h>

static void renderPage(NSUInteger page, CGContextRef ctx, CGPDFDocumentRef doc, ILPDFFormContainer *forms) {
    CGRect mediaRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(doc,page), kCGPDFMediaBox);
    CGRect cropRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(doc,page), kCGPDFCropBox);
    CGRect artRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(doc,page), kCGPDFArtBox);
    CGRect bleedRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(doc,page), kCGPDFBleedBox);
    UIGraphicsBeginPDFPageWithInfo(mediaRect, @{(NSString*)kCGPDFContextCropBox:[NSValue valueWithCGRect:cropRect],(NSString*)kCGPDFContextArtBox:[NSValue valueWithCGRect:artRect],(NSString*)kCGPDFContextBleedBox:[NSValue valueWithCGRect:bleedRect]});
    CGContextSaveGState(ctx);
    CGContextScaleCTM(ctx,1,-1);
    CGContextTranslateCTM(ctx, 0, -mediaRect.size.height);
    CGContextDrawPDFPage(ctx, CGPDFDocumentGetPage(doc,page));
    CGContextRestoreGState(ctx);
    for (ILPDFForm *form in forms) {
        if (form.page == page) {
            CGContextSaveGState(ctx);
            CGRect frame = form.frame;
            CGRect correctedFrame = CGRectMake(frame.origin.x-mediaRect.origin.x, mediaRect.size.height-frame.origin.y-frame.size.height-mediaRect.origin.y, frame.size.width, frame.size.height);
            CGContextTranslateCTM(ctx, correctedFrame.origin.x, correctedFrame.origin.y);
            [form vectorRenderInPDFContext:ctx forRect:correctedFrame];
            CGContextRestoreGState(ctx);
        }
    }
}

@implementation ILPDFDocument {
    NSString *_documentPath;
    ILPDFDictionary *_catalog;
    ILPDFDictionary *_info;
    ILPDFFormContainer *_forms;
    NSArray *_pages;
}

#pragma mark - NSObject

- (void)dealloc {
    CGPDFDocumentRelease(_document);
}

- (id)init {
    NSString *path = nil;
    self = [self initWithPath:path];
    return self;
}

#pragma mark - ILPDFDocument

- (instancetype)initWithData:(NSData *)data {
    NSParameterAssert(data);
    self = [super init];
    if (self != nil) {
        _document = [ILPDFUtility createPDFDocumentRefFromData:data];
        _documentData = [[NSMutableData alloc] initWithData:data];
    }
    return self;
}

- (instancetype)initWithResource:(NSString *)name {
    NSParameterAssert(name);
    self = [super init];
    if (self != nil) {
        if ([[[name componentsSeparatedByString:@"."] lastObject] isEqualToString:@"pdf"])
            name = [name substringToIndex:name.length-4];
        _document = [ILPDFUtility createPDFDocumentRefFromResource:name];
        _documentPath = [[NSBundle mainBundle] pathForResource:name ofType:@"pdf"] ;
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path {
    NSParameterAssert(path);
    self = [super init];
    if (self != nil) {
        _document = [ILPDFUtility createPDFDocumentRefFromPath:path];
        _documentPath = path;
    }
    return self;
}

- (void)refresh {
    _catalog = nil;
    _pages = nil;
    _info = nil;
    CGPDFDocumentRelease(_document);_document = NULL;
    _document = [ILPDFUtility createPDFDocumentRefFromData:self.documentData];
}

#pragma mark - Getters

- (ILPDFFormContainer *)forms {
    if (_forms == nil) {
        _forms = [[ILPDFFormContainer alloc] initWithParentDocument:self];
    }
    return _forms;
}

- (NSMutableData *)documentData {
    if (_documentData == nil) {
        _documentData = [[NSMutableData alloc] initWithContentsOfFile:_documentPath options:NSDataReadingMappedAlways error:NULL];
    }
    return _documentData;
}

- (ILPDFDictionary *)catalog {
    if (_catalog == nil) {
        _catalog = [[ILPDFDictionary alloc] initWithDictionary:CGPDFDocumentGetCatalog(_document)];
    }
    return _catalog;
}

- (ILPDFDictionary *)info {
    if (_info == nil) {
        _info = [[ILPDFDictionary alloc] initWithDictionary:CGPDFDocumentGetInfo(_document)];
    }
    return _info;
}

- (NSArray *)pages {
    if (_pages == nil) {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < CGPDFDocumentGetNumberOfPages(_document); i++) {
            [temp addObject:[[ILPDFPage alloc] initWithPage:CGPDFDocumentGetPage(_document,i+1)]];
        }
        _pages = [[NSArray alloc] initWithArray:temp];
    }
    return _pages;
}

- (NSUInteger)numberOfPages {
    return CGPDFDocumentGetNumberOfPages(_document);
}

#pragma mark - PDF File Saving and Converting


- (NSString *)formXML {
    return [self.forms formXML];
}

- (NSData *)savedStaticPDFData {
    NSUInteger numberOfPages = [self numberOfPages];
    NSMutableData *pageData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pageData, CGRectZero , nil);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (NSUInteger page = 1; page <= numberOfPages; page++) {
        renderPage(page, ctx, _document, self.forms);
    }
    UIGraphicsEndPDFContext();
    return pageData;
}


- (NSData *)mergedDataWithDocument:(ILPDFDocument *)docToAppend {
    NSMutableData *pageData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pageData, CGRectZero , nil);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (NSUInteger page = 1; page <= [self numberOfPages]; page++) {
        renderPage(page, ctx, _document, self.forms);
    }
    for (NSUInteger page = 1; page <= [docToAppend numberOfPages]; page++) {
        renderPage(page, ctx, docToAppend.document, docToAppend.forms );
    }
    UIGraphicsEndPDFContext();
    return pageData;
    
}

- (UIImage *)imageFromPage:(NSUInteger)page width:(NSUInteger)width {
    CGPDFDocumentRef doc = [ILPDFUtility createPDFDocumentRefFromData:[self savedStaticPDFData]];
    CGPDFPageRef pageref = CGPDFDocumentGetPage(doc, page);
    CGRect pageRect = CGPDFPageGetBoxRect(pageref, kCGPDFMediaBox);
    CGFloat pdfScale = width/pageRect.size.width;
    pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
    pageRect.origin = CGPointZero;
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,pageRect);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(pageref, kCGPDFMediaBox, pageRect, 0, true));
    CGContextDrawPDFPage(context, pageref);
    CGContextRestoreGState(context);
    UIImage *thm = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(doc);
    return thm;
}

@end
