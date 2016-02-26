//
//  ChatTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "PeppermintChatEntry.h"
#import "PlayingModel.h"
#import "AutoPlayModel.h"
#import "ChatEntryModel.h"

#define DISTANCE_TO_BORDER  5
#define TIMER_UPDATE_PERIOD 0.05


@implementation ChatTableViewCell {
    UIImage *imageConnected;
    UIImage *imageFlat;
    UIImage *imagePlay;
    UIImage *imagePause;
    NSTimer *timer;
    NSInteger totalSeconds;
    __block BOOL stopMessageReceived;
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
    stopMessageReceived = NO;
    REGISTER();
}

- (void) layoutSubviews {
    self.centerViewWidth.constant = self.frame.size.width * 0.60;
    self.durationCircleView.layer.cornerRadius = self.durationCircleView.frame.size.height/2;
    
    if(!self.peppermintChatEntry) {
        self.leftDistanceConstraint.constant = 2000;
    } else if(!self.peppermintChatEntry.isSentByMe) {
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

- (void) fillInformation:(PeppermintChatEntry*) chatEntry {
    
    self.spinnerView.hidden = YES;
    self.durationView.hidden = NO;
    self.durationViewWidthConstraint.constant = 0;
    self.durationCircleView.hidden = YES;
    
    [_playingModel.audioPlayer stop];
    _playingModel = nil;
    
    _peppermintChatEntry = chatEntry;
    self.playPauseImageView.image = imagePlay;
    self.playPauseImageView.hidden = NO;
    [self setLeftLabel];
    [self setRightLabelWithDate:chatEntry.dateCreated];
}

-(void) setLeftLabel {
    NSString *durationText = @"--:--";
    if(self.peppermintChatEntry && self.peppermintChatEntry.duration != 0) {
        totalSeconds = self.peppermintChatEntry.duration;
        BOOL isPlayingOrPaused = !self.durationCircleView.hidden;
        if(self.playingModel.audioPlayer.isPlaying || isPlayingOrPaused) {
            totalSeconds = self.playingModel.audioPlayer.currentTime;
        }
        NSInteger minutes = totalSeconds / 60;
        NSInteger seconds = totalSeconds % 60;
        durationText = [NSString stringWithFormat:@"%.2ld:%.2ld", (long)minutes, (long)seconds];
    }
    
    if(!self.peppermintChatEntry.isSeen) {
        durationText = [NSString stringWithFormat:@"(new) %@", durationText];
    }
    self.leftLabel.text = durationText;
}

-(void) setRightLabelWithDate:(NSDate*) date {
    NSUInteger timeInterval = (NSUInteger)[[NSDate date] timeIntervalSinceDate:date];
    NSTimeInterval timeVariable;
    NSString *timeText = nil;
    if(timeInterval > YEAR) {
        timeVariable = timeInterval / YEAR;
        timeText = LOC(@"Year", @"Year");
    } else if (timeInterval > MONTH) {
        timeVariable = timeInterval / MONTH;
        timeText = LOC(@"Month", @"Month");
    } else if (timeInterval > DAY) {
        timeVariable = timeInterval / DAY;
        timeText = LOC(@"Day", @"Day");
    } else if (timeInterval > HOUR) {
        timeVariable = timeInterval / HOUR;
        timeText = LOC(@"Hour", @"Hour");
    } else if (timeInterval > MINUTE) {
        timeVariable = timeInterval / MINUTE;
        timeText = LOC(@"Minute", @"Minute");
    } else if (timeInterval > SECOND) {
        timeVariable = timeInterval;
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
        PUBLISH([MessagePlayingStarted new]);
        if(!_playingModel || !_playingModel.audioPlayer.data ) {
            _playingModel = [PlayingModel alloc];
            self.spinnerView.hidden = NO;
            self.playPauseImageView.hidden = YES;
            weakself_create();
            dispatch_async(LOW_PRIORITY_QUEUE, ^{
                NSError *error = nil;
                if(!weakSelf.peppermintChatEntry.audio) {
                    NSURL *url = [NSURL URLWithString:self.peppermintChatEntry.audioUrl];
                    NSData *audioData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                    if(!error) {
                        weakSelf.peppermintChatEntry.audio = audioData;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.spinnerView.hidden = YES;
                    weakSelf.playPauseImageView.hidden = NO;
                    [[AutoPlayModel sharedInstance] clearScheduledPeppermintContact];
                    
                    if([self playAudio:weakSelf.peppermintChatEntry.audio]) {
                        
#warning "add ChatEntryModel and handle error situation"
                        weakSelf.peppermintChatEntry.isSeen = YES;
                        [[ChatEntryModel new] update:weakSelf.peppermintChatEntry];
                        
                        weakSelf.peppermintChatEntry.duration = _playingModel.audioPlayer.duration;
                        [weakSelf setLeftLabel];
                        weakSelf.durationCircleView.hidden = NO;
                        weakSelf.playPauseImageView.image = imagePause;
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

-(BOOL) playAudio:(NSData*)audioData {
    BOOL result = NO;
    if(audioData && !stopMessageReceived) {
        result = [_playingModel playData:audioData playerCompletitionBlock:^{
            PUBLISH([MessagePlayingEnded new]);
        }];
    }
    return result;
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

SUBSCRIBE(StopAllPlayingMessages) {
    stopMessageReceived = YES;
    [_playingModel.audioPlayer stop];
}

@end
