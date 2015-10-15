//
//  ContactTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.layer.borderColor  = [UIColor whiteColor].CGColor;
    self.cellSeperatorView.backgroundColor = [UIColor cellSeperatorGray];
    self.contactNameLabel.font = [UIFont openSansSemiBoldFontOfSize:17];
    self.contactViaCaptionLabel.font = [UIFont openSansSemiBoldFontOfSize:13];
    self.contactViaInformationLabel.font = [UIFont openSansSemiBoldFontOfSize:13];
    self.contactViaCaptionLabel.text = LOC(@"via", @"Localized value for the word via");
    [self applyNonSelectedStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected) {
        [self applySelectedStyle];
    } else {
        [self applyNonSelectedStyle];
    }
}

-(void) applySelectedStyle {
    self.backgroundColor = [UIColor peppermintGreen];
    self.avatarImageView.layer.borderWidth = 2;
    self.contactNameLabel.textColor = [UIColor whiteColor];
    self.contactViaCaptionLabel.textColor = [UIColor whiteColor];
    self.contactViaInformationLabel.textColor = [UIColor whiteColor];
}

-(void) applyNonSelectedStyle {
    self.backgroundColor = [UIColor whiteColor];
    self.avatarImageView.layer.borderWidth = 0;
    self.contactNameLabel.textColor = [UIColor blackColor];
    self.contactViaCaptionLabel.textColor = [UIColor textFieldTintGreen];
    self.contactViaInformationLabel.textColor = [UIColor viaInformationLabelTextGreen];
}

@end
