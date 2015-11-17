//
//  LoginTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginTableViewCell.h"

@implementation LoginTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.loginLabel setFont:[UIFont openSansSemiBoldFontOfSize:17]];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = LOGIN_CORNER_RADIUS;
    
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowRadius = 1;
}

-(IBAction)buttonTouched:(id)sender {
    self.alpha = 0.7;
}

-(IBAction)buttonReleasedOutside:(id)sender {
    self.alpha = 1;
}

-(IBAction)buttonReleasedInside:(id)sender {
    [self buttonReleasedOutside:sender];    
    [self.delegate selectedLoginTableViewCell:self atIndexPath:self.indexPath];
}

@end