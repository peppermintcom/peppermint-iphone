//
//  LoginValidateEmailTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 09/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginValidateEmailTableViewCell.h"

@implementation LoginValidateEmailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.informationLabel setFont:[UIFont openSansSemiBoldFontOfSize:18]];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

@end
