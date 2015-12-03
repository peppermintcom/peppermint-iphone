//
//  LoginTextFieldTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginTextFieldTableViewCell.h"

#define DONE_STRING         @"\n"

@implementation LoginTextFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.textField.font = [UIFont openSansSemiBoldFontOfSize:16];
    self.textField.textColor = [UIColor whiteColor];
    self.textField.tintColor = [UIColor whiteColor];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([string isEqualToString:DONE_STRING]) {
        [self.delegate doneButtonPressed];
    } else {
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decomposableCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
        
        [textField setTextContentInRange:range replacementString:string];
        [self.delegate updatedTextFor:self atIndexPath:self.indexPath];
    }
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.textField.text = @"";
    [self.delegate updatedTextFor:self atIndexPath:self.indexPath];
    return NO;
}

-(void) setValid:(BOOL) isValid {
    if(isValid) {
        self.coverView.layer.borderWidth = 0;
    } else {
        self.coverView.layer.borderWidth = 3;
        self.coverView.layer.borderColor = [UIColor warningColor].CGColor;
    }
}

@end