//
//  ILPDFSignatureEditingView.h
//  Pods
//
//  Created by Yuriy on 28/08/16.
//
//

#import <UIKit/UIKit.h>

@interface ILPDFSignatureEditingView : UIView

//need to add size
- (UIImage*) createImageFromSignWithMaxWidth:(CGFloat) width andMaxHeight:(CGFloat) height;
- (void) clearSignature;

@end
