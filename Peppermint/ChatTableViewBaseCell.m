//
//  ChatTableViewBaseCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatTableViewBaseCell.h"

#define DISTANCE_TO_BORDER                  5

@implementation ChatTableViewBaseCell {
    UIImage *imageConnected;
    UIImage *imageFlat;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor clearColor];
    imageConnected = [UIImage imageNamed:@"icon_chat_left_connected"];
    imageFlat = [UIImage imageNamed:@"icon_chat_left_flat"];
    
    self.messageView.layer.cornerRadius = 5;
}

- (void) layoutSubviews {
    self.contentView.backgroundColor = self.tableView.backgroundColor;
    self.centerViewWidth.constant = SCREEN_WIDTH * 0.75;
    if(!self.isSentByMe) {
        self.leftDistanceConstraint.constant = DISTANCE_TO_BORDER;
        self.leftImageView.image = imageConnected;
        self.rightImageView.image = [UIImage imageWithCGImage:imageFlat.CGImage
                                                        scale:imageFlat.scale
                                                  orientation:UIImageOrientationUpMirrored];
        
    } else {
        self.leftDistanceConstraint.constant = SCREEN_WIDTH
        - (self.centerViewWidth.constant
           + self.rightImageView.frame.size.width
           + DISTANCE_TO_BORDER);
        self.leftImageView.image = imageFlat;
        self.rightImageView.image = [UIImage imageWithCGImage:imageConnected.CGImage
                                                        scale:imageConnected.scale
                                                  orientation:UIImageOrientationUpMirrored];;
    }
    
    [super layoutSubviews];
}

-(BOOL) isSentByMe {
    return NO;
}

@end
