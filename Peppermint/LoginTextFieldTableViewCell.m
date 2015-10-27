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
    self.layer.cornerRadius = 15;
    self.textField.font = [UIFont openSansSemiBoldFontOfSize:17];
    self.textField.textColor = [UIColor blackColor];
    self.textField.tintColor = [UIColor textFieldTintGreen];
}

@end
