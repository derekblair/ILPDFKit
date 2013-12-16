
#import "AppDelegate.h"
#import "PDFViewController.h"
#import "PDFDocument.h"

@implementation AppDelegate
{
    PDFViewController* _pdfViewController;
        
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
        _pdfViewController = [[PDFViewController alloc] initWithResource:@"test"];
    }
    
    _pdfViewController.title = @"Sample PDF";
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:_pdfViewController];
    
    [self.window setRootViewController:navigationController];
   
    
     navigationController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem* saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    UIBarButtonItem* printBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStylePlain target:self action:@selector(print:)];
    
    [_pdfViewController.navigationItem setRightBarButtonItems:@[saveBarButtonItem,printBarButtonItem]];
   
    
    [self.window makeKeyAndVisible];
    return YES;
}


-(void)print:(id)sender
{
    [_pdfViewController openPrintInterfaceFromBarButtonItem:sender];
}


-(void)save:(id)sender
{
   if([_pdfViewController.document saveFormsToDocumentData])
   {
       [_pdfViewController.document writeToFile:@"test-after-save.pdf"];
       
       
       UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Saved to test-after-save.pdf in the app documents directory. This app will load this file the next time it is started." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
       [alertView show];
      
       
       
   }else
   {
       UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Save Failed. Make sure the PDF you are saving is not compressed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
       [alertView show];
   
   }
}

@end
