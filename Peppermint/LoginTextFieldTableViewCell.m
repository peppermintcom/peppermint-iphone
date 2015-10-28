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
    self.layer.cornerRadius = 5;
    self.textField.font = [UIFont openSansSemiBoldFontOfSize:12];
    self.textField.textColor = [UIColor blackColor];
    self.textField.tintColor = [UIColor textFieldTintGreen];
    self.textField.delegate = self;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.textField.text = text;
    [self.delegate updatedTextFor:self atIndexPath:self.indexPath];
    return NO;
}

@end