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
#import "ChatModel.h"
#import "AutoPlayModel.h"

#define DISTANCE_TO_BORDER  5
#define TIMER_UPDATE_PERIOD 0.05

@implementation ChatTableViewCell {
    UIImage *imageConnected;
    UIImage *imageFlat;
    UIImage *imagePlay;
    UIImage *imagePause;
    NSTimer *timer;
    NSUInteger totalSeconds;
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
    totalSeconds = 0;
}

- (void) layoutSubviews {
    self.centerViewWidth.constant = self.frame.size.width * 0.60;
    self.durationCircleView.layer.cornerRadius = self.durationCircleView.frame.size.height/2;
    
    if(!self.chatEntry) {
        self.leftDistanceConstraint.constant = 2000;
    } else if(!self.chatEntry.isSentByMe.boolValue) {
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
    
    
    [super layoutSubviews];
}

- (void) fillInformation:(ChatEntry*) chatEntry {
    
    self.spinnerView.hidden = YES;
    self.durationView.hidden = NO;
    self.durationViewWidthConstraint.constant = 0;
    self.durationCircleView.hidden = YES;
    
    [_playingModel.audioPlayer stop];
    _playingModel = nil;
    
    self.chatEntry = chatEntry;
    self.playPauseImageView.image = imagePlay;
    self.playPauseImageView.hidden = NO;
    [self setLeftLabel];
    [self setRightLabelWithDate:chatEntry.dateCreated];
}

-(void) setLeftLabel {
    NSString *durationText = @"--:--";
    if(self.chatEntry
       && self.chatEntry.duration
       && self.chatEntry.duration.integerValue != 0) {
        totalSeconds = self.chatEntry.duration.integerValue;
        BOOL isPlayingOrPaused = !self.durationCircleView.hidden;
        if(self.playingModel.audioPlayer.isPlaying || isPlayingOrPaused) {
            totalSeconds = self.playingModel.audioPlayer.currentTime;
        }
        NSInteger minutes = totalSeconds / 60;
        NSInteger seconds = totalSeconds % 60;
        durationText = [NSString stringWithFormat:@"%.2ld:%.2ld", (long)minutes, (long)seconds];
    }
    self.leftLabel.text = durationText;
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
                                                          toDate:[NSDate new]
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
    self.rightLabel.text = [NSString stringWithFormat:@"%ld %@ ago", (long)timeVariable, timeText].lowercaseString;
}

- (IBAction)playPauseButtonPressed:(id)sender {
    [self stopPlayingCell];
    if(_playingModel.audioPlayer.isPlaying) {
        self.playPauseImageView.image = imagePlay;
        [_playingModel pause];
    } else {
        if(!_playingModel || !_playingModel.audioPlayer.data ) {
            _playingModel = [PlayingModel alloc];
            self.spinnerView.hidden = NO;
            self.playPauseImageView.hidden = YES;
            weakself_create();
            dispatch_async(LOW_PRIORITY_QUEUE, ^{
                NSError *error = nil;
                if(!weakSelf.chatEntry.audio) {
                    NSURL *url = [NSURL URLWithString:self.chatEntry.audioUrl];
                    NSData *audioData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                    if(!error) {
                        weakSelf.chatEntry.audio = audioData;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.spinnerView.hidden = YES;
                    weakSelf.playPauseImageView.hidden = NO;
                    if(weakSelf.chatEntry.audio != nil && [_playingModel playData:weakSelf.chatEntry.audio playerCompletitionBlock:nil]) {
                        weakSelf.chatEntry.duration = [NSNumber numberWithInt:_playingModel.audioPlayer.duration];
                        [weakSelf setLeftLabel];
                        [ChatModel markChatEntryListened:weakSelf.chatEntry];
                        weakSelf.durationCircleView.hidden = NO;
                        weakSelf.playPauseImageView.image = imagePause;
                        [[AutoPlayModel sharedInstance] clearScheduledPeppermintContact];
                    }
                });
            });
        } else {
            [_playingModel play];
            self.durationCircleView.hidden = NO;
            self.playPauseImageView.image = imagePause;
        }
    }
}

-(void) updateDuration {
    if(_playingModel) {
        CGFloat percent = _playingModel.audioPlayer.currentTime / _playingModel.audioPlayer.duration;
        if( _playingModel.audioPlayer.isPlaying) {
            
            if((int)_playingModel.audioPlayer.currentTime != totalSeconds) {
                [self setLeftLabel];
            }
            
            CGFloat totalWidth = self.timelineView.frame.size.width - self.durationCircleView.frame.size.width;
            [self.messageView layoutIfNeeded];
            CGFloat destinationValue = totalWidth * percent;
            if(destinationValue > self.durationViewWidthConstraint.constant || destinationValue < 2) {
                [UIView animateWithDuration:TIMER_UPDATE_PERIOD animations:^{
                    self.durationViewWidthConstraint.constant = destinationValue;
                    [self.messageView layoutIfNeeded];
                }];
            }
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
