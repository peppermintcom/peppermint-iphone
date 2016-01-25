//
//  ChatTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "ChatEntry.h"

#define DISTANCE_TO_BORDER  5

@implementation ChatTableViewCell {
    UIImage *imageConnected;
    UIImage *imageFlat;
    UIImage *imagePlay;
    UIImage *imagePause;
    BOOL isPlaying;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.timelineView.layer.cornerRadius = 1;
    self.durationView.layer.cornerRadius = 1;
    imageConnected = [UIImage imageNamed:@"icon_chat_left_connected"];
    imageFlat = [UIImage imageNamed:@"icon_chat_left_flat"];
    imagePlay = [UIImage imageNamed:@"icon_play"];
    imagePause = [UIImage imageNamed:@"icon_pause"];
}

- (void) layoutSubviews {
    self.centerViewWidth.constant = self.frame.size.width * 0.60;
    [super layoutSubviews];
}

- (void) fillInformation:(ChatEntry*) chatEntry {
    if(chatEntry.isSentByMe.boolValue) {
        self.leftDistanceConstraint.constant = DISTANCE_TO_BORDER;
        self.leftImageView.image = imageConnected;
        self.rightImageView.image = [UIImage imageWithCGImage:imageFlat.CGImage
                                                        scale:imageFlat.scale
                                                  orientation:UIImageOrientationUpMirrored];
        
    } else {
        self.leftDistanceConstraint.constant = self.frame.size.width
        - (self.leftImageView.frame.size.width
           + self.centerViewWidth.constant
           + self.rightImageView.frame.size.width
           + DISTANCE_TO_BORDER);
        self.leftImageView.image = imageFlat;
        self.rightImageView.image = [UIImage imageWithCGImage:imageConnected.CGImage
                                                        scale:imageConnected.scale
                                                  orientation:UIImageOrientationUpMirrored];;
    }
    
    self.durationView.hidden = NO;
    
    self.durationViewWidthConstraint.constant = 13;
    
    isPlaying = NO;
    self.playPauseImageView.image = imagePlay;
    self.leftLabel.text = @"02:14";
    self.rightLabel.text = @"2 days";
}

- (IBAction)playPauseButtonPressed:(id)sender {
    isPlaying = !isPlaying;
    self.playPauseImageView.image = isPlaying ? imagePause : imagePlay;
}

@end
