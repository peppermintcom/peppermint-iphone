//
//  PlayingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "PlayingModel.h"
#import "AppDelegate.h"

@interface PlayingModel() <AVAudioPlayerDelegate> {
    NSString *audioPath;
}

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

-(void) dealloc {
    if(self.audioPlayer.isPlaying) {
        NSLog(@"Here is a problem man!! Audio should be stopped before dealloc.. ;)");
    }
    self.audioPlayer.delegate = nil;
}

-(void) initBeginRecordingSound {
    audioPath = [[NSBundle mainBundle]pathForResource:@"begin_record" ofType:@"mp3"];
}

-(void) initReceivedMessageSound {
    audioPath = [[NSBundle mainBundle]pathForResource:@"water_drop" ofType:@"mp3"];
}

-(void) prepareAudioForPath:(NSString*) myAudioPath {
    if (myAudioPath) {
        NSError *error;
        audioUrl = [NSURL fileURLWithPath:myAudioPath];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
        if(!error) {
            _audioPlayer.delegate = self;
            [_audioPlayer setNumberOfLoops:0];
        } else {
            [AppDelegate handleError:error];
        }
    } else {
        NSLog(@"Resource not found");
    }
}

-(BOOL) playPreparedAudiowithCompetitionBlock:(PlayerCompletitionBlock) playerCompletitionBlock {
    [self prepareAudioForPath:audioPath];
    cachedBlock = playerCompletitionBlock;
    [_audioPlayer stop];
    _audioPlayer.currentTime = 0;
    
    BOOL result = [self play];
    return result;
}

-(BOOL) playData:(NSData*) audioData playerCompletitionBlock:(PlayerCompletitionBlock) playerCompletitionBlock {
    NSError *error = nil;
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    _audioPlayer.delegate = self;
    if(!error) {
        cachedBlock = playerCompletitionBlock;
    } else {
        [AppDelegate handleError:error];
    }
    
    BOOL result = [self play];
    return result;
}

-(void) pause {    
    [_audioPlayer pause];
    [[AudioSessionModel sharedInstance] updateSessionState:NO];
}

-(BOOL) play {
    BOOL setSessionActive = [[AudioSessionModel sharedInstance] updateSessionState:YES];
    BOOL play = [_audioPlayer prepareToPlay] && [_audioPlayer play];
    BOOL result =  setSessionActive && play ;
    if(result) {
        [[AudioSessionModel sharedInstance] attachAVAudioProcessObject:_audioPlayer];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    } else {
        NSLog(@"Play call failed!!! setSessionActive:%d && play:%d", setSessionActive, play);
    }
    return result;
}

-(void) stop {
    [_audioPlayer stop];
    [[AudioSessionModel sharedInstance] updateSessionState:NO];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if(player == _audioPlayer && flag) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[AudioSessionModel sharedInstance] updateSessionState:NO];
        if(cachedBlock) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cachedBlock();
            });
        }
    }
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