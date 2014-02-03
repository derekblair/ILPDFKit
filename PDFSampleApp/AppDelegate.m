
#import "AppDelegate.h"
#import "PDFViewController.h"
#import "PDF.h"
#import "PDFDocument.h"

@implementation AppDelegate
{
    PDFViewController* _pdfViewController;
    UINavigationController* _navigationController;
        
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    
    // See if a set saved file already exists for demonstration purposes.
    NSString *path = [ [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"test-after-save.pdf"];
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        _pdfViewController = [[PDFViewController alloc] initWithPath:path];
    }
    else
    {
        _pdfViewController = [[PDFViewController alloc] initWithResource:@"testD.pdf"];
    }
    
    _pdfViewController.title = @"Sample PDF";
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_pdfViewController];
    
    [self.window setRootViewController:_navigationController];
   
    
     _navigationController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem* saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    UIBarButtonItem* printBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStylePlain target:self action:@selector(print:)];
    
    [_pdfViewController.navigationItem setRightBarButtonItems:@[saveBarButtonItem,printBarButtonItem]];
   
    
    [self.window makeKeyAndVisible];
    return YES;
}


-(void)print:(id)sender
{
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    [pic dismissAnimated:NO];
    // Save first, then print
    [_pdfViewController.document saveFormsToDocumentData:^(BOOL success) {
        
        
        if(pic && [UIPrintInteractionController canPrintData:_pdfViewController.document.documentData]) {
            
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = _pdfViewController.document.pdfName;
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            pic.printInfo = printInfo;
            pic.showsPageRange = YES;
            pic.printingItem = _pdfViewController.document.documentData;
            if(iPad)
            {
                [pic presentFromBarButtonItem:sender animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error){}];
            }else
            {
                [pic presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error){}];
            }
        }
        
    }];
}


-(void)save:(id)sender
{
   [_pdfViewController.document saveFormsToDocumentData:^(BOOL success) {
       
       if(success) {
           [_pdfViewController.document writeToFile:@"test-after-save.pdf"];
           UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Saved to test-after-save.pdf in the app documents directory. This app will load this file the next time it is started." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
           [alertView show];
       }else
       {
           UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Save Failed. Make sure you are not using object streams (PDF 1.5)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
           [alertView show];
           
       }

       
   }];
 }

@end
