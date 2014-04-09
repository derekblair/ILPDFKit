//  Created by Derek Blair on 2/24/2014.
//  Copyright (c) 2014 iwelabs. All rights reserved.

#import "PDFDocument.h"
#import "PDFForm.h"
#import "PDFDictionary.h"
#import "PDFArray.h"
#import "PDFStream.h"
#import "PDFPage.h"
#import "PDFUtility.h"
#import "PDFFormButtonField.h"
#import "PDFFormContainer.h"
#import "PDFSerializer.h"
#import "PDF.h"
#import <QuartzCore/QuartzCore.h>


#define isWS(c) ((c) == 0 || (c) == 9 || (c) == 10 || (c) == 12 || (c) == 13 || (c) == 32)


@interface PDFDocument()
@end


@implementation PDFDocument
{
    NSString* _documentPath;
    PDFDictionary* _catalog;
    PDFDictionary* _info;
    PDFFormContainer* _forms;
    NSArray* _pages;
}

-(void)dealloc
{
    CGPDFDocumentRelease(_document);
}

-(id)initWithData:(NSData *)data
{
    self = [super init];
    if(self != nil)
    {
        _document = [PDFUtility createPDFDocumentRefFromData:data];
        _documentData = [[NSMutableData alloc] initWithData:data];
    }
    return self;
}

-(id)initWithResource:(NSString *)name
{
    self = [super init];
    if(self != nil)
    {
        if([[[name componentsSeparatedByString:@"."] lastObject] isEqualToString:@"pdf"])
            name = [name substringToIndex:name.length-4];
        _document = [PDFUtility createPDFDocumentRefFromResource:name];
        _documentPath = [[NSBundle mainBundle] pathForResource:name ofType:@"pdf"] ;
    }
    return self;
}

-(id)initWithPath:(NSString*)path
{
    self = [super init];
    if(self != nil)
    {
        _document = [PDFUtility createPDFDocumentRefFromPath:path];
        _documentPath = path;
    }
    return self;
}


-(void)saveFormsToDocumentData:(void (^)(BOOL success))completion
{
    [PDFSerializer saveDocumentChanges:self.documentData basedOnForms:self.forms completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
             completion(success);
        });
    }];
}

-(void)writeToFile:(NSString*)name
{
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *path = [docsDirectory stringByAppendingPathComponent:name];
    [self.documentData writeToFile:path atomically:YES];
}


-(void)refresh
{
    _catalog = nil;
    _pages = nil;
    _info = nil;
    CGPDFDocumentRelease(_document);_document = NULL;
    _document = [PDFUtility createPDFDocumentRefFromData:self.documentData];
}



#pragma mark - Getter

-(PDFFormContainer*)forms
{
    if(_forms == nil)
    {
        _forms = [[PDFFormContainer alloc] initWithParentDocument:self];
    }
    
    return _forms;
}

-(NSMutableData*)documentData
{
    if(_documentData == nil)
    {
        _documentData = [[NSMutableData alloc] initWithContentsOfFile:_documentPath options:NSDataReadingMappedAlways error:NULL];
    }
    
    return _documentData;
}

-(PDFDictionary*)catalog
{
    if(_catalog == nil)
    {
        _catalog = [[PDFDictionary alloc] initWithDictionary:CGPDFDocumentGetCatalog(_document)];

    }
    
    return _catalog;
}

-(PDFDictionary*)info
{
    if(_info == nil)
    {
        _info = [[PDFDictionary alloc] initWithDictionary:CGPDFDocumentGetInfo(_document)];
    }
    
    return _info;
}

-(NSArray*)pages
{
    if(_pages == nil)
    {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        
        for(NSUInteger i = 0 ; i < CGPDFDocumentGetNumberOfPages(_document); i++)
        {
            PDFPage* add = [[PDFPage alloc] initWithPage:CGPDFDocumentGetPage(_document,i+1)];
                [temp addObject:add];
        }
        
        _pages = [[NSArray alloc] initWithArray:temp];
    }
    
    return _pages;
}

-(NSUInteger)numberOfPages
{
    return CGPDFDocumentGetNumberOfPages(_document);
}

#pragma mark - PDF File Saving and Converting


-(NSString*)formXML
{
    return [self.forms formXML];
}


-(NSData*)flattenedData;
{
    NSUInteger numberOfPages = [self numberOfPages];
    NSMutableData* pageData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pageData, CGRectZero , nil);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    for(NSUInteger page = 1; page <= numberOfPages;page++)
    {
        CGRect mediaRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document,page), kCGPDFMediaBox);
        CGRect cropRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document,page), kCGPDFCropBox);
        CGRect artRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document,page), kCGPDFArtBox);
        CGRect bleedRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document,page), kCGPDFBleedBox);
        
        UIGraphicsBeginPDFPageWithInfo(mediaRect, @{(NSString*)kCGPDFContextCropBox:[NSValue valueWithCGRect:cropRect],(NSString*)kCGPDFContextArtBox:[NSValue valueWithCGRect:artRect],(NSString*)kCGPDFContextBleedBox:[NSValue valueWithCGRect:bleedRect]});
        
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx,1,-1);
        CGContextTranslateCTM(ctx, 0, -mediaRect.size.height);
        CGContextDrawPDFPage(ctx, CGPDFDocumentGetPage(_document,page));
        CGContextRestoreGState(ctx);
        
        for(PDFForm* form in self.forms)
        {
            if(form.page == page) {
                CGContextSaveGState(ctx);
                CGRect frame = form.frame;
                CGRect correctedFrame = CGRectMake(frame.origin.x-mediaRect.origin.x, mediaRect.size.height-frame.origin.y-frame.size.height-mediaRect.origin.y, frame.size.width, frame.size.height);
                CGContextTranslateCTM(ctx, correctedFrame.origin.x, correctedFrame.origin.y);
                [form vectorRenderInPDFContext:ctx forRect:correctedFrame];
                CGContextRestoreGState(ctx);
            }
        }
    }
    
    UIGraphicsEndPDFContext();
    
    return pageData;
}


-(UIImage*)imageFromPage:(NSUInteger)page width:(NSUInteger)width
{
    CGPDFDocumentRef doc = [PDFUtility createPDFDocumentRefFromData:[self flattenedData]];
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
