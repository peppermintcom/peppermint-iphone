//
//  ShowAllContactsTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 30/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "ShowAllContactsTableViewCell.h"

@implementation ShowAllContactsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.centerView.backgroundColor = [UIColor emailLoginColor];
    self.centerView.layer.cornerRadius = SHOW_ALL_CONTACRS_CORNER_RADIUS;
    
    self.centerView.layer.shadowOffset = CGSizeMake(0, 4);
    self.centerView.layer.shadowColor = [UIColor shadowGreen].CGColor;
    self.centerView.layer.shadowOpacity = 1;
    self.centerView.layer.shadowRadius = 1;
    
    self.titleLabel.text = LOC(@"Show All Contacts", @"Title");
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:17];
}

-(IBAction)showAllContactsButtonPressed:(id)sender {
    [self.delegate showAllContactsButtonPressed];
}

@end
