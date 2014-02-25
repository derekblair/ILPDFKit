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
    NSString* _sourceCode;
    NSString* _documentPath;
    PDFDictionary* _catalog;
    PDFDictionary* _info;
    PDFFormContainer* _forms;
    NSArray* _pages;
}

-(void)dealloc
{
   
    self.documentData = nil;
    self.pdfName = nil;
    [_documentPath release];
    [_catalog release];
    [_info release];
    [_pages release];
    [_forms release];
    [_sourceCode release];
    CGPDFDocumentRelease(_document);
    [super dealloc];
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
        _documentPath = [[[NSBundle mainBundle] pathForResource:name ofType:@"pdf"] retain];
    }
    return self;
}

-(id)initWithPath:(NSString*)path
{
    self = [super init];
    if(self != nil)
    {
        _document = [PDFUtility createPDFDocumentRefFromPath:path];
        _documentPath = [path retain];
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
    [_catalog release];_catalog = nil;
    [_pages release];_pages = nil;
    [_info release];_info = nil;
    [_sourceCode release];_sourceCode = nil;
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
            [add release];
        }
        
        _pages = [[NSArray alloc] initWithArray:temp];
        [temp release];
    }
    
    return _pages;
}

-(NSUInteger)numberOfPages
{
    return CGPDFDocumentGetNumberOfPages(_document);
}

#pragma mark - PDF File Saving


-(NSString*)formXML
{
    return [self.forms formXML];
}






@end
