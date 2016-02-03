//
//  ChatTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "ChatEntry.h"
#import "PlayingModel.h"

#define DISTANCE_TO_BORDER  5
#define TIMER_UPDATE_PERIOD 0.05

@implementation ChatTableViewCell {
    UIImage *imageConnected;
    UIImage *imageFlat;
    UIImage *imagePlay;
    UIImage *imagePause;
    NSTimer *timer;
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
    timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_UPDATE_PERIOD target:self selector:@selector(updateDuration) userInfo:nil repeats:YES];
}

- (void) layoutSubviews {
    self.centerViewWidth.constant = self.frame.size.width * 0.60;
    self.durationCircleView.layer.cornerRadius = self.durationCircleView.frame.size.height/2;
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
    self.durationViewWidthConstraint.constant = 0;
    self.durationCircleView.hidden = YES;
    
    NSInteger minutes = chatEntry.duration.integerValue / 60;
    NSInteger seconds = chatEntry.duration.integerValue % 60;
    self.leftLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld", minutes, seconds];
    [self setRightLabelWithDate:chatEntry.dateCreated];
    
    self.playPauseImageView.image = imagePlay;
    _playingModel = [PlayingModel alloc];
    if([_playingModel playData:chatEntry.audio playerCompletitionBlock:^{ [self playPauseButtonPressed:nil]; }]) {
        _playingModel.audioPlayer.volume = 1.0;
        [_playingModel pause];
    }
    
}

-(void) setRightLabelWithDate:(NSDate*) date {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components: (NSCalendarUnitHour
                                                                   | NSCalendarUnitMinute
                                                                   | NSCalendarUnitSecond
                                                                   | NSCalendarUnitDay
                                                                   | NSCalendarUnitMonth
                                                                   | NSCalendarUnitYear )
                                                        fromDate:date
                                                          toDate:[NSDate date]
                                                         options:0];
    NSInteger timeVariable;
    NSString *timeText = nil;
    if(components.year > 0) {
        timeVariable = components.year;
        timeText = LOC(@"Year", @"Year");
    } else if (components.month > 0) {
        timeVariable = components.month;
        timeText = LOC(@"Month", @"Month");
    } else if (components.day > 0) {
        timeVariable = components.day;
        timeText = LOC(@"Day", @"Day");
    } else if (components.minute > 0) {
        timeVariable = components.minute;
        timeText = LOC(@"Minute", @"Minute");
    } else if (components.second > 0) {
        timeVariable = components.second;
        timeText = LOC(@"Second", @"Second");
    } else {
        timeVariable = 0;
        self.rightLabel.text = LOC(@"Just Now", @"Just Now");
        return;
    }
    
    if(timeVariable > 1) {
        timeText = [NSString stringWithFormat:@"%@%@", timeText, LOC(@"Plural Suffix", @"Plural Suffix")];
    }
    self.rightLabel.text = [NSString stringWithFormat:@"%ld %@", timeVariable, timeText].lowercaseString;
}


- (IBAction)playPauseButtonPressed:(id)sender {
    [self stopPlayingCell];
    if(_playingModel.audioPlayer.isPlaying) {
        [_playingModel pause];
        self.playPauseImageView.image = imagePlay;
    } else {
        [_playingModel play];
        self.durationCircleView.hidden = NO;
        self.playPauseImageView.image = imagePause;
    }
}

-(void) updateDuration {
    if(_playingModel) {
        CGFloat percent = _playingModel.audioPlayer.currentTime / _playingModel.audioPlayer.duration;
        if( _playingModel.audioPlayer.isPlaying) {
            CGFloat totalWidth = self.timelineView.frame.size.width - self.durationCircleView.frame.size.width;
            self.durationViewWidthConstraint.constant = totalWidth * percent;
        } else {
            self.playPauseImageView.image = imagePlay;
            if(percent < 0.00001) {
                self.durationViewWidthConstraint.constant = 0;
                self.durationCircleView.hidden = YES;
            }
        }
    }
}

-(void) stopPlayingCell {
    for(ChatTableViewCell *cell in [self.tableView visibleCells]) {
        if(cell != self && cell.playingModel.audioPlayer.isPlaying) {
            [cell.playingModel.audioPlayer stop];
            cell.playPauseImageView.image = imagePlay;
        }
    }
}

@end
