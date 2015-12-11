//
//  LoginTextFieldTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginTextFieldTableViewCell.h"

@implementation LoginTextFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.textField.font = [UIFont openSansSemiBoldFontOfSize:16];
    self.textField.textColor = [UIColor whiteColor];
    self.textField.tintColor = [UIColor whiteColor];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidChange :(UITextField *)textField {
    [self.delegate updatedTextFor:self atIndexPath:self.indexPath];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate textFieldDidBeginEdiging:textField];
}

-(BOOL) isTextAllowed:(NSString*) string {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decomposableCharacterSet]];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
    for(NSString *notAllowedString in self.notAllowedCharactersArray) {
        if([string containsString:notAllowedString]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL result = NO;
    if([string isEqualToString:DONE_STRING]) {
        [self.delegate doneButtonPressed];
    } else if (textField.isSecureTextEntry) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self.delegate updatedTextFor:self atIndexPath:self.indexPath];
    } else if ([self isTextAllowed:string]) {
        result = YES;
    }
    return result;
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