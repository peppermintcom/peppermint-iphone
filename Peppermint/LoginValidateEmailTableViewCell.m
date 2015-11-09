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
    
    self.buttonBorderView.backgroundColor = [UIColor whiteColor];
    self.buttonBorderView.layer.cornerRadius = 15;
    [self.buttonTitleLabel setFont:[UIFont openSansSemiBoldFontOfSize:18]];
    self.buttonTitleLabel.textColor = [UIColor emailLoginColor];    
}

-(IBAction)buttonTouched:(id)sender {
    self.buttonBorderView.alpha = 0.7;
}

-(IBAction)buttonReleasedOutside:(id)sender {
    self.buttonBorderView.alpha = 1;
}

-(IBAction)buttonReleasedInside:(id)sender {
    [self buttonReleasedOutside:sender];
    [self.delegate resendValidation];
}

@end
