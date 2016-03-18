//
//  PlayingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "PlayingModel.h"
#import "ProximitySensorModel.h"

@interface PlayingModel() <AVAudioPlayerDelegate>

@end

@implementation PlayingModel {
    NSURL *audioUrl;
    PlayerCompletitionBlock cachedBlock;
}

-(id) init {
    self = [super init];
    if(self) {
        cachedBlock = nil;
        _audioPlayer = nil;
        [self initBeginRecordingSound];
        REGISTER();
    }
    return self;
}

-(void) initBeginRecordingSound {
    NSString *audioPath = [[NSBundle mainBundle]pathForResource:@"begin_record" ofType:@"mp3"];
    [self prepareAudioForPath:audioPath];
}

-(void) initReceivedMessageSound {
    NSString *audioPath = [[NSBundle mainBundle]pathForResource:@"water_drop" ofType:@"mp3"];
    [self prepareAudioForPath:audioPath];
}

-(void) prepareAudioForPath:(NSString*) audioPath {
    if (audioPath) {
        audioUrl = [NSURL fileURLWithPath:audioPath];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
        [_audioPlayer setNumberOfLoops:0];
        [_audioPlayer prepareToPlay];
        _audioPlayer.delegate = self;
        [_audioPlayer play];
        [_audioPlayer stop];
    } else {
        NSLog(@"Resource not found");
    }
}

-(BOOL) playPreparedAudiowithCompetitionBlock:(PlayerCompletitionBlock) playerCompletitionBlock {
    cachedBlock = playerCompletitionBlock;
    [_audioPlayer stop];
    _audioPlayer.currentTime = 0;
    
    BOOL result = [_audioPlayer play];
    return result;
}

-(BOOL) playData:(NSData*) audioData playerCompletitionBlock:(PlayerCompletitionBlock) playerCompletitionBlock {
    NSError *error = [self updateCategory];
    if(!error) {
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
        _audioPlayer.delegate = self;
        if(!error) {
            cachedBlock = playerCompletitionBlock;
            [_audioPlayer prepareToPlay];
        }
    }
    
    BOOL result = [_audioPlayer play];
    return result;
}

-(void) pause {
    [_audioPlayer pause];
}

-(void) play {
    NSError *error = [self updateCategory];
    if(!error) {
        [_audioPlayer play];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if(player == _audioPlayer && flag ) {
        if(cachedBlock) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cachedBlock();
            });
        }
    }
}

#pragma mark - ProximitySensor

-(NSError*) updateCategory {
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if(!error) {
        ProximitySensorModel *proximitySensorModel = [ProximitySensorModel sharedInstance];
        BOOL isOnEar = proximitySensorModel.isDeviceOrientationCorrectOnEar && proximitySensorModel.isDeviceCloseToUser;
        if(isOnEar) {
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        } else {
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        }
    }
    return error;
}

SUBSCRIBE(ProximitySensorValueIsUpdated) {
    [self updateCategory];
}

#warning "Fade animation can be added to voice"
/*
#pragma mark - Cross Fade
- (void) crossFadePlayerOne:(AVAudioPlayer *)player1 andPlayerTwo:(AVAudioPlayer *)player2 withCompletion:(void(^)())completion{
    CGFloat fadeSpeed = DEFAULT_FADE_SPEED;
    if([player1 volume] > 0) {
        [player1 setVolume:[player1 volume] - fadeSpeed];
        [player2 setVolume:[player2 volume] + fadeSpeed];
        NSLog(@"Audio2 volume %.4f", player2.volume);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC),dispatch_get_main_queue(),^{
            [self crossFadePlayerOne:player1 andPlayerTwo:player2 withCompletion:completion];
        });
    } else {
        if(completion){
            completion();
        }
    }
}
*/

@end