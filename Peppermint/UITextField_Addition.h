//
//  UITextField_Addition.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (UITextField_Addition)

-(void) setTextContentInRange:(NSRange)range replacementString:(NSString *)string;

@end
