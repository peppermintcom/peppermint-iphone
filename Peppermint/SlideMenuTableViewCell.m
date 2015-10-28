//
//  SlideMenuTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "SlideMenuTableViewCell.h"

@implementation SlideMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor slideMenuTableViewCellTextLabelColor];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:17];
}

@end
