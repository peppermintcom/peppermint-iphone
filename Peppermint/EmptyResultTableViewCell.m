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
    self.headerLabel.textColor = [UIColor emptyResultTableViewCellHeaderLabelTextcolorGray];
    self.headerLabel.text = LOC(@"No contacts have been found", @"Empty cell header text");
    
    self.footerLabel.textColor = [UIColor textFieldTintGreen];
    self.footerLabel.text = LOC(@"No contacts explanation", @"Text that will give information");
    
    [self setVisibiltyOfExplanationLabels:NO];
}

-(void) setVisibiltyOfExplanationLabels:(BOOL) visibility {
    self.headerLabel.hidden = !visibility;
    self.footerLabel.hidden = !visibility;
}


@end
