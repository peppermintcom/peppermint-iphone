//
//  InformationTextTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 11/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "InformationTextTableViewCell.h"

@implementation InformationTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];    
    self.backgroundColor = [UIColor clearColor];
    self.label.textColor = [UIColor whiteColor];
    [self.label setFont:[UIFont openSansFontOfSize:13]];
}

@end
