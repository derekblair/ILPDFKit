//
//  ILPDFKit.m
//  ILPDFKit
//
//  Created by Brock Haymond on 3/21/14.
//  Copyright (c) 2014 Interact. All rights reserved.
//

#import "ILPDFKit.h"

#import "PDF.h"

BOOL debugForms = FALSE;

@interface ILPDFKit ()
{
    id _file;
    BOOL hasStatusBar;
    PDFViewController* _pdfViewController;
    UIPopoverController *activityPopover;
}

//@property (strong, nonatomic) UIPopoverController *activityPopover;

@end

@implementation ILPDFKit

- (id)initWithPDF:(id)file
{
    self = [super init];
    if (self)
    {
        _file = file;
        if([file isKindOfClass:[NSData class]])
        {
            _pdfViewController = [[PDFViewController alloc] initWithData:file];
        }
        else if([[NSFileManager defaultManager] fileExistsAtPath:file])
        {
            _pdfViewController = [[PDFViewController alloc] initWithPath:file];
        }
        else if([[NSFileManager defaultManager] fileExistsAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file]])
        {
            _pdfViewController = [[PDFViewController alloc] initWithResource:file];
        }
        else {
            file = nil;
            _pdfViewController = [[PDFViewController alloc] initWithData:nil];
        }
        
        self.navigationBar.translucent = FALSE;
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self setViewControllers:@[_pdfViewController]];
        
        UIBarButtonItem* doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        [_pdfViewController.navigationItem setLeftBarButtonItems:@[doneBarButtonItem]];
        
        if(!file) {
            dispatch_async(dispatch_get_main_queue(),^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"File not found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            });
            return self;
        }
        
        if([_file isKindOfClass:[NSString class]])
            _pdfViewController.title = [_file lastPathComponent];
        
        UIBarButtonItem* actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openActivitySheet:)];
        [_pdfViewController.navigationItem setRightBarButtonItems:@[actionBarButtonItem]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
        [self.view addGestureRecognizer:tap];
        
        if(![UIApplication sharedApplication].statusBarHidden)
            hasStatusBar = TRUE;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backgroundTap
{
    //Check to see if the keyboard is being closed, if so don't move in or out of fullscreen
    if(_pdfViewController.pdfView->keyboardClosed) {
        _pdfViewController.pdfView->keyboardClosed = FALSE;
        return;
    }
    
    //Fade background in and out for fullscreen
    if(!self.navigationBarHidden)
        [_pdfViewController setBackColor:[UIColor blackColor] animated:TRUE];
    else
        [_pdfViewController setBackColor:nil animated:TRUE];
    
    //Hide the status bar only if present
    if(hasStatusBar)
        [[UIApplication sharedApplication] setStatusBarHidden:!self.navigationBarHidden withAnimation:UIStatusBarAnimationFade];
    
    [self setNavigationBarHidden:!self.navigationBarHidden animated:TRUE];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{}];
}

- (IBAction)openActivitySheet:(UIBarButtonItem*)sender
{
    //Get the PDF title.
    NSString *title = @"Attachment-1.pdf";
    if([_file isKindOfClass:[NSString class]])
        title = [_file lastPathComponent];
    
    //Write the PDF to a temp file.
    NSString *path = [NSTemporaryDirectory() stringByAppendingString:title];
    [[_pdfViewController.document flattenedData] writeToFile:path atomically:TRUE];
    
    //Create an activity view controller with the PDF as its activity item.
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:path]] applicationActivities:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is.
        [_pdfViewController presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        //iPad, present the view controller inside a popover.
        if (![activityPopover isPopoverVisible]) {
            activityPopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            [activityPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            //Dismiss if the button is tapped while popover is visible.
            [activityPopover dismissPopoverAnimated:YES];
        }
    }
}

- (void)setTitle:(NSString *)title
{
    _pdfViewController.title = title;
}

- (void)setValue:(NSString*)value forFormWithName:(NSString*)name
{
    [_pdfViewController.document.forms setValue:value ForFormWithName:name];
}

- (void)setDebugForms:(BOOL)v
{
    NSLog(@"%s %d", __FUNCTION__, v);
    debugForms = v;
}

@end
