//
//  ILAppDelegate.m
//  ILPDFKitSample
//
//  Created by Derek Blair on 3/3/2014.
//  Copyright (c) 2015 Iwe Labs. All rights reserved.
//

#import "PDF.h"
#import "PDFFormContainer.h"
#import "ILAppDelegate.h"

@implementation ILAppDelegate {
    PDFViewController *_pdfViewController;
    UINavigationController *_navigationController;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    _pdfViewController = [[PDFViewController alloc] initWithResource:@"testA.pdf"];
    _pdfViewController.title = @"Sample PDF";
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_pdfViewController];
    [self.window setRootViewController:_navigationController];
    _navigationController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    [_pdfViewController.navigationItem setRightBarButtonItems:@[saveBarButtonItem]];
    
    
    for (PDFForm *form in _pdfViewController.document.forms) {
        NSLog(@"Found a form with name %@",form.name);
    }
    
    [_pdfViewController.document.forms setValue:@"This was set in ILAppDelegate.m" forFormWithName:@"PersonalInformation[0].Surname[0]"];
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)save:(id)sender {
    NSData *savedStaticData = [_pdfViewController.document savedStaticPDFData];
    [_pdfViewController removeFromParentViewController];
    _pdfViewController = [[PDFViewController alloc] initWithData:savedStaticData];
    _pdfViewController.title = @"Saved Static PDF";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Complete" message:@"The displayed PDF file is a static version of the previous file, but with the form values added. The starting PDF has not been modified and this static PDF no longer contains forms." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [_navigationController setViewControllers:@[_pdfViewController]];
}



@end
