//
//  AudioSessionModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 01/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioSessionModel : BaseModel

@property (weak, nonatomic) AVAudioRecorder *activeAudioRecorder;
@property (weak, nonatomic) AVAudioPlayer   *activeAudioPlayer;

+ (instancetype) sharedInstance;
-(BOOL) updateSessionState:(BOOL) destinationSessionState isForRecording:(BOOL) isForRecording;
-(void) checkAndUpdateRoutingIfNeeded;

@end
