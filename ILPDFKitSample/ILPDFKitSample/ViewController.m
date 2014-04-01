//
//  ViewController.m
//  ILPDFKitTest
//
//  Created by Brock Haymond on 3/21/14.
//  Copyright (c) 2014 Interact. All rights reserved.
//

#import "ViewController.h"

#import "ILPDFKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)viewPDF:(id)sender
{
    ILPDFKit *ilpdf = [[ILPDFKit alloc] initWithPDF:@"testA.pdf"];
    [self presentViewController:ilpdf animated:YES completion:^{}];
}

@end
