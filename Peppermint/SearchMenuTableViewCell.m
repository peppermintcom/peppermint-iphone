//
//  SearchMenuTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 10/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SearchMenuTableViewCell.h"

@implementation SearchMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cellSeperatorView.backgroundColor = [UIColor cellSeperatorGray];
    self.iconImageName = @"icon_mail";
    self.iconHighlightedImageName = @"icon_mail_touch";
    self.cellTag = -1;
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
    self.titleLabel.textColor = [UIColor whiteColor];
    self.iconImageView.image = [UIImage imageNamed:self.iconHighlightedImageName];
}

-(void) applyNonSelectedStyle {
    self.backgroundColor = [UIColor whiteColor];
    self.titleLabel.textColor = [UIColor viaInformationLabelTextGreen];
    self.iconImageView.image = [UIImage imageNamed:self.iconImageName];
}

- (IBAction)MenuItemPressed:(id)sender {
    [self setSelected:YES animated:YES];
}

- (IBAction)MenuItemFocusLost:(id)sender {
    [self setSelected:NO animated:YES];
}

- (IBAction)MenuItemReleased:(id)sender {
    [self MenuItemFocusLost:sender];
    [self.delegate cellSelectedWithTag:self.cellTag];
}
@end
