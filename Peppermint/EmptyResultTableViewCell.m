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
    [self setHeaderLabelText];
    [self setFooterLabelText];
    [self setVisibiltyOfExplanationLabels:NO];
}

-(void) setHeaderLabelText {
    self.headerLabel.textColor = [UIColor emptyResultTableViewCellHeaderLabelTextcolorGray];
    self.headerLabel.text = LOC(@"No contacts have been found", @"Empty cell header text");
}

-(void) setFooterLabelText {
    NSString *footerLabelText = LOC(@"No contacts explanation", @"Text that will give information");
    NSMutableAttributedString *footerAttributedText = [[NSMutableAttributedString alloc] initWithString:footerLabelText];
    //NSRange peppermintRange = [footerLabelText rangeOfString:LOC(@"Peppermint", @"Text to be with attribute")];
    //[footerAttributedText addAttribute:NSForegroundColorAttributeName value:[UIColor peppermintGreen] range:peppermintRange];
    self.footerLabel.textColor = [UIColor textFieldTintGreen];
    self.footerLabel.attributedText = footerAttributedText;
}

-(void) setVisibiltyOfExplanationLabels:(BOOL) visibility {
    self.headerLabel.hidden = !visibility;
    self.footerLabel.hidden = !visibility;
}


@end
