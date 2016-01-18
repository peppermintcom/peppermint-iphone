//
//  PlayingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "PlayingModel.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayingModel() <AVAudioPlayerDelegate>

@end

@implementation PlayingModel {
    AVAudioPlayer *audioPlayer;
    NSURL *beginRecordingUrl;
    PlayerCompletitionBlock cachedBlock;
}

-(id) init {
    self = [super init];
    if(self) {
        cachedBlock = nil;
        audioPlayer = nil;
        NSString *beginRecordingPath = [[NSBundle mainBundle]pathForResource:@"begin_record" ofType:@"mp3"];
        if (beginRecordingPath) {
            beginRecordingUrl = [NSURL fileURLWithPath:beginRecordingPath];
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beginRecordingUrl error:nil];
            [audioPlayer setNumberOfLoops:1];
            [audioPlayer prepareToPlay];
            audioPlayer.delegate = self;
            [audioPlayer play];
            [audioPlayer stop];
        } else {
            NSLog(@"Resource not found");
        }
    }
    return self;
}

-(BOOL) playBeginRecording:(PlayerCompletitionBlock) playerCompletitionBlock {
    cachedBlock = playerCompletitionBlock;
    [audioPlayer stop];
    return [audioPlayer play];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if(player == audioPlayer && flag ) {
        if(cachedBlock) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cachedBlock();
            });
        }
    }
}

@end