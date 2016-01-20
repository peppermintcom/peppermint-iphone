//
//  ChatContactTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatContactTableViewCell.h"

@implementation ChatContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    int fontSize = 12;
    self.rightDateLabel.font = [UIFont openSansSemiBoldFontOfSize:fontSize];
    self.rightDateLabel.textColor = [UIColor textFieldTintGreen];
    
    self.rightMessageCounterLabel.font = [UIFont openSansSemiBoldFontOfSize:fontSize];
    self.rightMessageCounterLabel.backgroundColor = [UIColor viaInformationLabelTextGreen];
    self.rightMessageCounterLabel.textColor = [UIColor whiteColor];
    self.rightMessageCounterLabel.layer.cornerRadius = 4;
}

@end
