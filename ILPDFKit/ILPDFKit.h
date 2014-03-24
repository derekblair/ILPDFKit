//
//  ILPDFKit.h
//  ILPDFKit
//
//  Created by Brock Haymond on 3/21/14.
//  Copyright (c) 2014 Interact. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILPDFKit : UINavigationController

- (id)initWithPDF:(id)file;
- (void)setTitle:(NSString *)title;
- (void)setValue:(NSString*)value forFormWithName:(NSString*)name;

/**---------------------------------------------------------------------------------------
 * @name Debugging
 *  ---------------------------------------------------------------------------------------
 */

/** Sets the acroforms to display form names when entered.
 @param debug Set to TRUE to log the form name.
 */
-(void)setDebugForms:(BOOL)debug;

@end
