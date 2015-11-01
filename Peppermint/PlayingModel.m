//
//  PlayingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "PlayingModel.h"
#import <AVFoundation/AVFoundation.h>

@implementation PlayingModel {
    AVAudioPlayer *player;
    NSURL *beginRecordingUrl;
}

-(id) init {
    self = [super init];
    if(self) {
     
        NSString *beginRecordingPath = [[NSBundle mainBundle]pathForResource:@"begin_record" ofType:@"mp3"];
        if (beginRecordingPath) {
            beginRecordingUrl = [NSURL fileURLWithPath:beginRecordingPath];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:beginRecordingUrl error:nil];
            [player setNumberOfLoops:1];
            [player prepareToPlay];
            [player play];
            [player stop];
        } else {
            NSLog(@"Resource not found");
        }
    }
    return self;
}

-(void) playBeginRecording {
    [player play];
    //while ([player isPlaying]) {}
}

@end