//
//  PlayingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "PlayingModel.h"
#import "AppDelegate.h"

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

-(void) dealloc {
    if(self.audioPlayer.isPlaying) {
        NSLog(@"Here is a problem man!! Audio should be stopped before dealloc.. ;)");
    }
    self.audioPlayer.delegate = nil;
}

-(void) initBeginRecordingSound {
    _audioPath = [[NSBundle mainBundle]pathForResource:@"begin_record" ofType:@"mp3"];
}

-(void) initReceivedMessageSound {
    _audioPath = [[NSBundle mainBundle]pathForResource:@"water_drop" ofType:@"mp3"];
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
    [self prepareAudioForPath:self.audioPath];
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
    CGFloat cachedVolume = _audioPlayer.volume;
    _audioPlayer.volume = 0;
    BOOL setSessionActive = [[AudioSessionModel sharedInstance] updateSessionState:YES];
    BOOL play = [_audioPlayer prepareToPlay] && [_audioPlayer play];
    BOOL result =  setSessionActive && play ;
    if(result) {
        [_audioPlayer fadeVolumeInToLevel:[NSNumber numberWithFloat:cachedVolume]];
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

-(BOOL) isEqual:(id)object {
    if (![object isKindOfClass:[PlayingModel class]]) {
        return NO;
    }
    
    PlayingModel * other = (PlayingModel *)object;
    BOOL result = [other.audioPath isEqual:self.audioPath]
    || other.audioPlayer == self.audioPlayer
    || [other.audioPlayer.data isEqual:self.audioPlayer.data];
    return result;
}

@end