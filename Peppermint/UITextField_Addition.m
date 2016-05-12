//
//  UITextField_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 12/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "UITextField_Addition.h"

@implementation UITextField (UITextField_Addition)

-(void) updateKeyboardReturnType:(UIReturnKeyType) returnKeyType {    
    if(self.returnKeyType != returnKeyType) {
        self.returnKeyType = returnKeyType;
        UITextRange *range = [self selectedTextRange];
        [self resignFirstResponder];
        [self becomeFirstResponder];
        [self setSelectedTextRange:range];
    }
}

@end
