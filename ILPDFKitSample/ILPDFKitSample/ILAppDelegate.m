//
//  ILAppDelegate.m
//  ILPDFKitSample
//
//  Created by Derek Blair on 3/3/2014.
//  Copyright (c) 2015 Iwe Labs. All rights reserved.
//

#import "ILAppDelegate.h"
#import "PDFViewController.h"
#import "PDF.h"
#import "PDFDocument.h"

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
    [self.window makeKeyAndVisible];
    return YES;
}


-(void)save:(id)sender {
    [[_pdfViewController.document savedStaticPDFData] writeToFile:@"testASaved.pdf" atomically:YES];
}


@end
