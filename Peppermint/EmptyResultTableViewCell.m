//
//  EmptyResultTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "EmptyResultTableViewCell.h"

@implementation EmptyResultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    [self setHeaderLabelText];
    [self setVisibiltyOfExplanationLabels:NO];
}

-(void) setHeaderLabelText {
    self.headerLabel.textColor = [UIColor emptyResultTableViewCellHeaderLabelTextcolorGray];
    self.headerLabel.font = [UIFont openSansSemiBoldFontOfSize:14];
    self.headerLabel.text = LOC(@"No contacts have been found", @"Empty cell header text");
}

-(void) setVisibiltyOfExplanationLabels:(BOOL) visibility {
    self.headerLabel.hidden = !visibility;
}

@end
