//
//  EmailLoginCollectionViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 25/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "EmailLoginCollectionViewCell.h"

#define CORNDER_RADIUS      15
#define FONT_SIZE           14

@implementation EmailLoginCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = CORNDER_RADIUS;
    
    self.informationlabel.font = [UIFont openSansSemiBoldFontOfSize:FONT_SIZE];
    
    self.subInformationLabel.font = [UIFont openSansBoldFontOfSize:FONT_SIZE-5];
    self.subInformationLabel.text = LOC(@"COMING SOON", @"Coming Soon Text");
}

-(void) setIsActive:(BOOL) active {
    [self setBorder:!active];
    self.subInformationLabel.hidden = active;
    if(active) {
        self.informationlabel.font = [UIFont openSansBoldFontOfSize:FONT_SIZE];
        self.backgroundColor = [UIColor whiteColor];
        self.informationlabel.textColor = [UIColor emptyResultTableViewCellHeaderLabelTextcolorGray];
        self.subInformationLabel.textColor = [UIColor privacyPolicyGreen];
    } else {
        self.informationlabel.font = [UIFont openSansSemiBoldFontOfSize:FONT_SIZE];
        self.backgroundColor = [UIColor clearColor];
        self.informationlabel.textColor = [UIColor progressCoverViewGreen];
        self.subInformationLabel.textColor = [UIColor progressCoverViewGreen];
    }
}

-(void) setBorder:(BOOL) active {
    self.layer.borderColor =[[UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_pattern"]] CGColor];
    if(active) {
        self.layer.borderWidth = 2;
    } else {
        self.layer.borderWidth = 0;
    }
}

@end
