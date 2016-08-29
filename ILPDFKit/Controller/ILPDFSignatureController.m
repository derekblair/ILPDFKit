//
//  ILPDFSignatureController.m
//  Pods
//
//  Created by Yuriy on 28/08/16.
//
//

#import "ILPDFSignatureController.h"
#import "ILPDFSignatureEditingView.h"

@interface ILPDFSignatureController ()
@property (strong, nonatomic) IBOutlet ILPDFSignatureEditingView *signatureView;

@end

@implementation ILPDFSignatureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)clearAction:(UIButton *)sender {
    
    [self.signatureView clearSignature];
    
}

- (IBAction)signatureAction:(UIButton *)sender {
    
    [self.delegate signedWithImage:[self.signatureView createImageFromSignWithMaxWidth:self.expectedSignSize.width andMaxHeight:self.expectedSignSize.height]];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
