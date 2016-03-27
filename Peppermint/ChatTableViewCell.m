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
#import "PlayingChatEntryModel.h"

#define DISTANCE_TO_BORDER  5
#define TIMER_UPDATE_PERIOD 0.05
#define REWIND_TIME_DURING_SPEAKER_UPDATE   2

@interface ChatTableViewCell () <ChatEntryModelDelegate>
@end

@implementation ChatTableViewCell {
    UIImage *imageConnected;
    UIImage *imageFlat;
    UIImage *imagePlay;
    UIImage *imagePause;
    NSTimer *timer;
    NSTimeInterval totalSeconds;
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
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    totalSeconds = 0;
    stopMessageReceived = NO;
    _chatEntryModel = [ChatEntryModel new];
    _chatEntryModel.delegate = self;
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
    _playingModel = [[PlayingChatEntryModel sharedInstance] playModelForChatEntry:chatEntry];
    self.durationCircleView.hidden = (_playingModel == nil);
    if(self.durationCircleView.hidden) {
        self.durationViewWidthConstraint.constant = 0;
    }
    
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
        NSInteger seconds = totalSeconds - (60 * minutes);
        durationText = [NSString stringWithFormat:@"%.2ld:%.2ld", (long)minutes, (long)seconds];
    }
    
    if(!self.peppermintChatEntry.isSeen) {
        self.leftLabel.textColor = [UIColor peppermintCancelOrange];
    } else {
        self.leftLabel.textColor = [UIColor textFieldTintGreen];
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
        [self.delegate stoppedPlayingMessage:self];
    } else {
        [self.delegate startedPlayingMessage:sender ? self : nil];
        if(!_playingModel || !_playingModel.audioPlayer.data ) {
            _playingModel = [PlayingModel alloc];
            self.spinnerView.hidden = NO;
            [self.spinnerView startAnimating];
            
            self.playPauseImageView.hidden = YES;
            weakself_create();
            dispatch_async(LOW_PRIORITY_QUEUE, ^{
                NSError *error = nil;
                if(!weakSelf.peppermintChatEntry.audio) {
                    NSURL *url = [NSURL URLWithString:self.peppermintChatEntry.audioUrl];
                    NSData *audioData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                    if(!error) {
                        weakSelf.peppermintChatEntry.audio = audioData;
                    } else {
                        [self.delegate playMessageInCell:self gotError:error];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.spinnerView.hidden = YES;
                    weakSelf.playPauseImageView.hidden = NO;
                    [[AutoPlayModel sharedInstance] clearScheduledPeppermintContact];
                    
                    if([self playAudio:weakSelf.peppermintChatEntry.audio]) {
                        [self stopPlayingCell];
                        weakSelf.peppermintChatEntry.isSeen = YES;
                        [weakSelf.chatEntryModel savePeppermintChatEntry:weakSelf.peppermintChatEntry];
                        
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
    if(stopMessageReceived) {
        stopMessageReceived = !stopMessageReceived;
    } else if(audioData) {
        result = [_playingModel playData:audioData playerCompletitionBlock:^{
            [self.delegate stoppedPlayingMessage:self];
        }];
        
        if(result) {
            [[PlayingChatEntryModel sharedInstance] setCachedPlayingModel:_playingModel];
        }        
    }
    return result;
}

-(void) updateDuration {
    if(_playingModel) {
        CGFloat percent = _playingModel.audioPlayer.currentTime / _playingModel.audioPlayer.duration;
        BOOL isPlayingOrPaused = !self.durationCircleView.hidden;
        if( _playingModel.audioPlayer.isPlaying || isPlayingOrPaused) {
            self.durationCircleView.hidden = NO;
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
            self.durationCircleView.hidden = (percent < 0.00001);
            if(self.durationCircleView.hidden) {
                self.durationViewWidthConstraint.constant = 0;
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
    if(!self.spinnerView.hidden) {
        stopMessageReceived = YES;
    } else {
        [_playingModel.audioPlayer stop];
    }
}

-(IBAction)touchMoved:(id)sender withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    CGFloat totalWidth = self.timelineView.frame.size.width ;
    
    CGFloat newConstant = currentPoint.x
    - self.leftDistanceConstraint.constant
    - self.timelineView.frame.origin.x
    - self.leftImageView.frame.size.width;
    BOOL isValidGesture = (newConstant > 0 && newConstant < totalWidth) && _playingModel;
    
    if(isValidGesture) {
        [self stopPlayingCell];
        [_playingModel.audioPlayer pause];
        self.durationCircleView.hidden = NO;
        self.durationViewWidthConstraint.constant = newConstant;
        CGFloat currentWidth = self.durationView.frame.size.width;
        NSTimeInterval totalTime = _playingModel.audioPlayer.duration;
        _playingModel.audioPlayer.currentTime = (currentWidth/totalWidth) * totalTime;
        [self setLeftLabel];
    }
}

-(IBAction)touchEndOutside:(id)sender withEvent:(UIEvent *)event {
    if(_playingModel) {
        [self playPauseButtonPressed:sender];
    }
}

#pragma mark - ChatEntryModelDelegate

-(void) operationFailure:(NSError*) error {
    [self.delegate operationFailure:error];
}

-(void) peppermintChatEntriesArrayIsUpdated {
    NSLog(@"peppermintChatEntriesArrayIsUpdated");
}

-(void) peppermintChatEntrySavedWithSuccess:(NSArray*) savedPeppermintChatEnryArray {
    NSLog(@"peppermintChatEntrySavedWithSuccess");
}

#pragma mark - Raise to listen on built-in headset

-(void) rewindPlayer {
    NSTimeInterval timeInterval = self.playingModel.audioPlayer.currentTime;
    timeInterval = timeInterval > REWIND_TIME_DURING_SPEAKER_UPDATE ? timeInterval-REWIND_TIME_DURING_SPEAKER_UPDATE : 0;
    [self.playingModel.audioPlayer setCurrentTime:timeInterval];
}


SUBSCRIBE(ProximitySensorValueIsUpdated) {
    BOOL isPlaying = (self.playingModel.audioPlayer.isPlaying);
    if(isPlaying) {
        if(!event.isDeviceCloseToUser) {
            [self.playingModel.audioPlayer pause];
            [self.delegate stoppedPlayingMessage:self];
        } else if (event.isDeviceOrientationCorrectOnEar) {
            [self rewindPlayer];
        }
    }
}

@end
