//
//  AVAudioPlayer_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 05/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "AVAudioPlayer_Addition.h"

@implementation AVAudioPlayer (AVAudioPlayer_Addition)

-(void)fadeVolumeInToLevel:(NSNumber*)finalLevel
{
    if (self.volume < finalLevel.floatValue) {
        self.volume = self.volume + 0.1;
        [self performSelector:@selector(fadeVolumeInToLevel:) withObject:finalLevel afterDelay:0.1];
    }
}

-(void)fadeVolumeOut
{
    if (self.volume > 0.1) {
        self.volume = self.volume - 0.1;
        [self performSelector:@selector(fadeVolumeOut) withObject:nil afterDelay:0.1];
    } else {
        [self stop];
    }
}

@end
