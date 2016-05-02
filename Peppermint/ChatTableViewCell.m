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

#define DISTANCE_TO_BORDER                  5
#define TIMER_UPDATE_PERIOD                 0.05
#define REWIND_TIME_DURING_SPEAKER_UPDATE   2

#define MAX_SEEK_RATIO                      0.97

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
    PeppermintChatEntry *referencedChatEntry;
    __block BOOL isSeeking;
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
    isSeeking = NO;
    REGISTER();
}

- (void) dealloc {
    [timer invalidate];
    timer = nil;
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
    
    referencedChatEntry = chatEntry;
    _peppermintChatEntry = [chatEntry copy];
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
    isSeeking = NO;
    if(_playingModel.audioPlayer.isPlaying) {
        [self stopPlayingCell];
        self.playPauseImageView.image = imagePlay;
        [_playingModel pause];
        [self.delegate stoppedPlayingMessage:self];
    } else {
        [self.delegate startedPlayingMessage:self];
        if(!_playingModel || !_playingModel.audioPlayer.data ) {
            _playingModel = [PlayingModel new];
            
            self.spinnerView.hidden = NO;
            [self.spinnerView startAnimating];
            
            self.playPauseImageView.hidden = YES;
            weakself_create();
            dispatch_async(LOW_PRIORITY_QUEUE, ^{
                [weakSelf.chatEntryModel markAllPreviousMessagesAsRead:weakSelf.peppermintChatEntry];
                NSError *error = nil;
                if(!weakSelf.peppermintChatEntry.audio) {
                    NSString *audioUrlToFetch = weakSelf.peppermintChatEntry.audioUrl;
                    if(audioUrlToFetch) {
                        NSURL *url = [NSURL URLWithString:audioUrlToFetch];
                        NSData *audioData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                        if(!error) {
                            weakSelf.peppermintChatEntry.audio = audioData;
                        } else {
                            [weakSelf.delegate playMessageInCell:weakSelf gotError:error];
                            return;
                        }
                    }
                }
                
                if(weakSelf.peppermintChatEntry.audio) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        strongSelf_create();
                        if(strongSelf) {
                            strongSelf.spinnerView.hidden = YES;
                            strongSelf.playPauseImageView.hidden = NO;
                            [[AutoPlayModel sharedInstance] clearScheduledPeppermintContact];
                            
                            if([strongSelf playAudio:strongSelf.peppermintChatEntry.audio]) {
                                [strongSelf stopPlayingCell];
                                [[PlayingChatEntryModel sharedInstance] cachePlayingModel:_playingModel forChatEntry:strongSelf.peppermintChatEntry];
                                strongSelf.peppermintChatEntry.isSeen = YES;
                                [strongSelf.chatEntryModel savePeppermintChatEntry:strongSelf.peppermintChatEntry];
                                
                                strongSelf.peppermintChatEntry.duration = _playingModel.audioPlayer.duration;
                                [strongSelf setLeftLabel];
                                strongSelf.durationCircleView.hidden = NO;
                                strongSelf.playPauseImageView.image = imagePause;
                            }
                        }
                    });
                }
            });
        } else {
            [self stopPlayingCell];
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
        weakself_create();
        result = [_playingModel playData:audioData playerCompletitionBlock:^{
            PlayingModel *cachedPlayingModel = [[PlayingChatEntryModel sharedInstance] playModelForChatEntry:weakSelf.peppermintChatEntry];
            if([cachedPlayingModel isEqual:weakSelf.playingModel]) {
                [[PlayingChatEntryModel sharedInstance] cachePlayingModel:nil forChatEntry:nil];
            }
            [weakSelf.delegate stoppedPlayingMessage:weakSelf];
        }];
    }
    return result;
}

-(void) updateDuration {
    if(_playingModel && !isSeeking) {
        double percent = _playingModel.audioPlayer.currentTime / _playingModel.audioPlayer.duration;
        self.durationCircleView.hidden = (percent < 0.00001);
        self.playPauseImageView.image = _playingModel.audioPlayer.isPlaying ? imagePause : imagePlay;
        if( _playingModel.audioPlayer.isPlaying && ((int)_playingModel.audioPlayer.currentTime != totalSeconds)) {
                [self setLeftLabel];
        }
        
        if(self.durationCircleView.hidden) {
            self.durationViewWidthConstraint.constant = 0;
        } else if (_playingModel.audioPlayer.isPlaying || _playingModel.audioPlayer.currentTime > 0.5) {
            CGFloat totalWidth = self.timelineView.frame.size.width - self.durationCircleView.frame.size.width;
            [self.messageView layoutIfNeeded];
            double destinationValue = totalWidth * percent;
            weakself_create();
            [UIView animateWithDuration:TIMER_UPDATE_PERIOD animations:^{
                weakSelf.durationViewWidthConstraint.constant = destinationValue;
                [weakSelf.messageView layoutIfNeeded];
            }];
        }
    }
}

-(void) stopPlayingCell {
    PlayingModel *cachedPlayingModel = [[PlayingChatEntryModel sharedInstance] playModelForChatEntry:self.peppermintChatEntry];
    if(![self.playingModel isEqual:cachedPlayingModel]) {
        [cachedPlayingModel stop];
    }
    for(UITableViewCell *cell in [self.tableView visibleCells]) {
        if([cell isKindOfClass:[ChatTableViewCell class]]) {
            ChatTableViewCell *chatTableViewCell = (ChatTableViewCell*)cell;
            if(chatTableViewCell != self && chatTableViewCell.playingModel.audioPlayer.isPlaying) {
                [chatTableViewCell.playingModel stop];
                chatTableViewCell.playPauseImageView.image = imagePlay;
            }
        }
    }
}

SUBSCRIBE(ApplicationDidBecomeActive) {
    PlayingModel *cachedPlayingModel = [[PlayingChatEntryModel sharedInstance] playModelForChatEntry:self.peppermintChatEntry];
    if(cachedPlayingModel.audioPlayer.isPlaying) {
        [cachedPlayingModel.audioPlayer stop];
    }
}

SUBSCRIBE(StopAllPlayingMessages) {
    if(!self.spinnerView.hidden) {
        stopMessageReceived = YES;
    } else {
        [_playingModel stop];
        [self.delegate stoppedPlayingMessage:self];
    }
}

-(IBAction)touchMoved:(id)sender withEvent:(UIEvent *)event {
    isSeeking = YES;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint currentPoint = [touch locationInView:self.timelineView];
    double totalWidth = self.timelineView.frame.size.width ;
    #warning "Current Version seems to work nice. However consider to refactor for cleaner code"
    CGFloat minValue = 0.5;
    CGFloat maxValue = totalWidth * MAX_SEEK_RATIO;
    
    __block double newConstant = currentPoint.x;
    if(newConstant <= minValue) {
        newConstant = minValue;
    } else if (newConstant >= maxValue) {
        newConstant = maxValue;
    }
    BOOL isValidGesture = (newConstant >= minValue && newConstant <= maxValue) && _playingModel;
    if(isValidGesture) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopPlayingCell];
            [_playingModel.audioPlayer pause];
            self.durationCircleView.hidden = NO;
            NSTimeInterval totalTime = _playingModel.audioPlayer.duration;
            newConstant *= MAX_SEEK_RATIO;
            self.durationViewWidthConstraint.constant = newConstant;
            _playingModel.audioPlayer.currentTime = (newConstant/maxValue) * totalTime;
            [self setLeftLabel];
        });
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
    referencedChatEntry.isSeen = self.peppermintChatEntry.isSeen;
    referencedChatEntry.audio = self.peppermintChatEntry.audio;
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
            [self.playingModel pause];
            [self.delegate stoppedPlayingMessage:self];
        } else if (event.isDeviceCloseToUser && event.isDeviceOrientationCorrectOnEar) {
            [self rewindPlayer];
        }
    }
}

- (void) resetContent {
    PlayingModel *cachedPlayingModel = [[PlayingChatEntryModel sharedInstance] playModelForChatEntry:self.peppermintChatEntry];
    if(![_playingModel isEqual:cachedPlayingModel]) {
        [_playingModel stop];
    }
}

@end
