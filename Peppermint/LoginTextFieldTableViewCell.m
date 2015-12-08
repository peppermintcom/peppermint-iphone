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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate updatedTextFor:self atIndexPath:self.indexPath];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([string isEqualToString:DONE_STRING]) {
        [self.delegate doneButtonPressed];
    } else if(self.notAllowedCharacters.length == 0 || ![self.notAllowedCharacters containsString:string]) {
        [textField setTextContentInRange:range replacementString:string];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decomposableCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
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
    return;
#warning "If it will not come settings to isValid view. These below code can be deleted"
/*
    if(isValid) {
        self.coverView.layer.borderWidth = 0;
    } else {
        self.coverView.layer.borderWidth = 0;
        self.coverView.layer.borderColor = [UIColor warningColor].CGColor;
    }
*/
}

@end