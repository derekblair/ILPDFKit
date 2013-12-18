
#import "PDFViewController.h"
#import "PDFDocument.h"
#import "PDFView.h"
#import "PDFFormContainer.h"
#import "PDFUIAdditionElementView.h"
#import "PDF.h"

@interface PDFViewController()
    -(void)loadPDFView;
    -(PDFDocument*)createMergedDocumentAfterApplyingPaths:(NSArray*)paths ViewWidth:(CGFloat)width Margin:(CGFloat)margin;
    -(CGRect)currentFrame:(UIInterfaceOrientation)o;
    -(CGPoint)getMargins;
@end

@implementation PDFViewController



-(void)dealloc
{
    [self removeFromParentViewController];
    [_pdfView removeFromSuperview];
    self.pdfView = nil;
    self.document = nil;
    
    [super dealloc];
}


-(id)initWithData:(NSData*)data
{
    self = [super init];
    if(self != nil)
    {
        
        _document = [[PDFDocument alloc] initWithData:data];
    }
    return self;
}

-(id)initWithResource:(NSString*)name
{
    self = [super init];
    if(self!=nil)
    {
        _document = [[PDFDocument alloc] initWithResource:name];
    }
    return self;
}

-(id)initWithPath:(NSString*)path
{
    self = [super init];
    if(self != nil)
    {
        _document = [[PDFDocument alloc] initWithPath:path];
    }
    
    return self;
}

-(CGRect)currentFrame:(UIInterfaceOrientation)o
{
    
    
    
    if(UIInterfaceOrientationIsPortrait(o))
    {
        return CGRectMake(0, 0, PDFDeviceMinorDimension, PDFDeviceMajorDimension);
    }
    else
    {
        return CGRectMake(0, 0, PDFDeviceMajorDimension, PDFDeviceMinorDimension);
    }
    
   
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
   
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    
    self.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.opaque = YES;
    [self loadPDFView];
}




-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _pdfView.alpha = 0;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

    for(PDFForm* form in self.document.forms)
    {
        [form removeObservers];
    }
    
    [_pdfView removeFromSuperview];self.pdfView = nil;
    [self loadPDFView];
    
}


-(BOOL)openPrintInterfaceFromBarButtonItem:(UIBarButtonItem*)bbi
{
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    [pic dismissAnimated:NO];
    pic.delegate = self;
    PDFDocument* printd = [self createMergedDocument];
    
    if(pic && [UIPrintInteractionController canPrintData:printd.documentData]) {
        
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = _document.pdfName;
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            pic.printInfo = printInfo;
            pic.showsPageRange = YES;
            pic.printingItem = printd.documentData;
        if(iPad)
        {
            [pic presentFromBarButtonItem:bbi animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error){}];
        }else
        {
            [pic presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error){}];
        }
        [printd release];
        return YES;
        
    }
    
    [printd release];
    return NO;
}



-(PDFDocument*)createMergedDocument
{
   CGPoint margins = [self getMargins];
    return [self createMergedDocumentAfterApplyingPaths:@[] ViewWidth:self.view.bounds.size.width Margin:margins.x];
}

#pragma mark - Printing


-(PDFDocument*)createMergedDocumentAfterApplyingPaths:(NSArray*)paths ViewWidth:(CGFloat)width Margin:(CGFloat)margin
{
    NSUInteger numberOfPages = [_document numberOfPages];
   
    CGFloat maxWidth = 0;
    
    for(PDFPage* pg in self.document.pages)
    {
        if([pg cropBox].size.width > maxWidth)maxWidth = [pg cropBox].size.width;
    }
   
    CGFloat widthScale = (maxWidth/(width-2*margin));
    
    NSMutableData* ret = [[NSMutableData data] retain];
    
    
    CGFloat canvasWidth = PDFDefaultCanvasWidth;
    CGFloat canvasHeight = PDFDefaultCanvasHeight;
    
    CGRect tempRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document.document,1), kCGPDFCropBox);
    
    if(tempRect.size.width>tempRect.size.height)
    {
        canvasWidth = PDFDefaultCanvasHeight;
        canvasHeight = PDFDefaultCanvasWidth;
    }
    
    
    UIGraphicsBeginPDFContextToData(ret, CGRectMake(0, 0, canvasWidth, canvasHeight), nil);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    for(NSUInteger page = 1; page <= numberOfPages;page++)
    {

        UIGraphicsBeginPDFPage();
        
        CGRect mediaRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(_document.document,page), kCGPDFCropBox);
        
        CGFloat pwidth = mediaRect.size.width;
        CGFloat pheight = mediaRect.size.height;
        
        CGFloat mX = (canvasWidth-pwidth)/2.0;
        CGFloat mY = (canvasHeight-pheight)/2.0;
        
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx,1,-1);
        CGContextTranslateCTM(ctx, mX, -canvasHeight+mY*2);
        CGContextDrawPDFPage(ctx, CGPDFDocumentGetPage(_document.document,page));
        
        
        
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx,0,-((page-1)*(canvasHeight+margin*widthScale)));
        CGContextScaleCTM(ctx,widthScale,widthScale);
        CGContextTranslateCTM(ctx,-margin,-margin);
        
    
        for(PDFUIAdditionElementView* additionElementView in _pdfView.pdfUIAdditionElementViews)
        {
            CGContextSaveGState(ctx);
            CGContextTranslateCTM(ctx, additionElementView.baseFrame.origin.x, additionElementView.baseFrame.origin.y);
            [additionElementView vectorRenderInPDFContext:ctx ForRect:additionElementView.baseFrame];
            CGContextRestoreGState(ctx);
        }
        
        CGContextRestoreGState(ctx);
        
        
    }
    UIGraphicsEndPDFContext();
    PDFDocument* retdoc = [[PDFDocument alloc] initWithData:ret];
    [ret release];
    return retdoc;
}

-(void)reload
{
    [_document refresh];
    [_pdfView removeFromSuperview];
    [_pdfView release];
    [self loadPDFView];
}

-(void)setBackColor:(UIColor*)color
{
    _pdfView.pdfView.backgroundColor = color;
}

#pragma mark - Hidden

-(void)loadPDFView
{
    id pass = (_document.documentPath?_document.documentPath:_document.documentData);
    
   CGRect frm = [self currentFrame:self.interfaceOrientation];
    
    
    self.view.frame = CGRectMake(0,self.view.frame.origin.y,frm.size.width,frm.size.height-self.view.frame.origin.y);
    
    CGPoint margins = [self getMargins];
    
    NSArray* additionViews = [_document.forms createUIAdditionViewsForSuperviewWithWidth:frm.size.width Margin:margins.x HMargin:margins.y];
        _pdfView = [[PDFView alloc] initWithFrame:self.view.bounds DataOrPath:pass AdditionViews:additionViews];
    [additionViews release];
    [self.view addSubview:_pdfView];
}

#pragma mark - UIPrintInteractionControllerDelegate

-(void)printInteractionControllerWillPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
}

-(void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController
{
}


 -(CGPoint)getMargins
{
    if(iPad)
    {
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))return CGPointMake(PDFPortraitPadWMargin,PDFPortraitPadHMargin);
        else return CGPointMake(PDFLandscapePadWMargin,PDFLandscapePadHMargin);
    }
    else
    {
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))return CGPointMake(PDFPortraitPhoneWMargin,PDFPortraitPhoneHMargin);
        else return CGPointMake(PDFLandscapePhoneWMargin,PDFLandscapePhoneHMargin);
    }
}



@end
