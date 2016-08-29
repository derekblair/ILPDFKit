//
//  ILPDFSignatureController.h
//  Pods
//
//  Created by Yuriy on 28/08/16.
//
//

#import <UIKit/UIKit.h>
@protocol ILPDFSignatureControllerDelegate;

@interface ILPDFSignatureController : UIViewController

@property (nonatomic, weak)   IBOutlet id <ILPDFSignatureControllerDelegate> delegate;
@property (assign) CGSize expectedSignSize;
@end

@protocol ILPDFSignatureControllerDelegate <NSObject>
@optional

- (void) signedWithImage:(UIImage*) signatureImage;

@end