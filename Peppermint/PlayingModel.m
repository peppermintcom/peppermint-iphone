//
//  PlayingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "PlayingModel.h"

@interface PlayingModel() <AVAudioPlayerDelegate>

@end

@implementation PlayingModel {
    NSURL *beginRecordingUrl;
    PlayerCompletitionBlock cachedBlock;
}

-(id) init {
    self = [super init];
    if(self) {
        cachedBlock = nil;
        _audioPlayer = nil;
        NSString *beginRecordingPath = [[NSBundle mainBundle]pathForResource:@"begin_record" ofType:@"mp3"];
        if (beginRecordingPath) {
            beginRecordingUrl = [NSURL fileURLWithPath:beginRecordingPath];
            _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beginRecordingUrl error:nil];
            [_audioPlayer setNumberOfLoops:1];
            [_audioPlayer prepareToPlay];
            _audioPlayer.delegate = self;
            [_audioPlayer play];
            [_audioPlayer stop];
        } else {
            NSLog(@"Resource not found");
        }
    }
    return self;
}

-(BOOL) playBeginRecording:(PlayerCompletitionBlock) playerCompletitionBlock {
    cachedBlock = playerCompletitionBlock;
    [_audioPlayer stop];
    return [_audioPlayer play];
}

-(BOOL) playData:(NSData*) audioData playerCompletitionBlock:(PlayerCompletitionBlock) playerCompletitionBlock {
    NSError *error;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory :AVAudioSessionCategoryPlayback error:&error];
    
    if(!error) {
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
        if(!error) {
            cachedBlock = playerCompletitionBlock;
            [_audioPlayer prepareToPlay];
        }
    }
    
    return [_audioPlayer play];
}

-(void) pause {
    [_audioPlayer pause];
}

-(void) play {
    [_audioPlayer play];
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

@end