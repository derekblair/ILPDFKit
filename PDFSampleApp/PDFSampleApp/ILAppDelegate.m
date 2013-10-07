
#import "ILAppDelegate.h"
#import "PDFViewController.h"
#import "PDFDocument.h"

@implementation ILAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    
    
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *path = [docsDirectory stringByAppendingPathComponent:@"test-after-save.pdf"];
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
    [_pdfViewController release];
    [navigationController release];
    
    UIBarButtonItem* saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    UIBarButtonItem* printBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStylePlain target:self action:@selector(print:)];
    
    [_pdfViewController.navigationItem setRightBarButtonItems:@[saveBarButtonItem,printBarButtonItem]];
    [saveBarButtonItem release];
    [printBarButtonItem release];
    
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
       
       
       UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Save Complete" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
       [alertView show];
       [alertView release];
       
       
   }else
   {
       UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Save Failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
       [alertView show];
       [alertView release];
   }
}

@end
