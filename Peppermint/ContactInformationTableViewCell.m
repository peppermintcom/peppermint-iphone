//
//  ContactInformationTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 30/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactInformationTableViewCell.h"

@implementation ContactInformationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.centerView.layer.cornerRadius = SHOW_ALL_CONTACRS_CORNER_RADIUS;
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:17];
}

-(IBAction) contactInformationButtonPressed:(id)sender {
    [self.delegate contactInformationButtonPressed];
}

-(void) setViewForAddNewContact {
    self.iconImageView.image = [UIImage imageNamed:@"icon_add"];
    self.titleLabel.text = LOC(@"Add Contact", @"Title");
    self.titleLabel.textColor = [UIColor whiteColor];
    self.centerView.backgroundColor = [UIColor emailLoginColor];
    self.centerView.layer.shadowOffset = CGSizeMake(0, 4);
    self.centerView.layer.shadowColor = [UIColor shadowGreen].CGColor;
    self.centerView.layer.shadowOpacity = 1;
    self.centerView.layer.shadowRadius = 1;
}

-(void) setViewForShowAllContacts {
    self.iconImageView.image = [UIImage imageNamed:@"icon_all"];
    self.titleLabel.text = LOC(@"All Contacts", @"Title");
    self.titleLabel.textColor = [UIColor emailLoginColor];
    self.centerView.backgroundColor = [UIColor clearColor];
    self.centerView.layer.shadowOffset = CGSizeMake(0, 0);
    self.centerView.layer.shadowColor = [UIColor clearColor].CGColor;
    self.centerView.layer.shadowOpacity = 0;
    self.centerView.layer.shadowRadius = 0;
}

@end
