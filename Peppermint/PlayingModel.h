//
//  PlayingModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import <AVFoundation/AVFoundation.h>

typedef void(^PlayerCompletitionBlock)(void);

@interface PlayingModel : BaseModel
@property (strong, nonatomic, readonly) AVAudioPlayer *audioPlayer;

-(void) initBeginRecordingSound;
-(void) initReceivedMessageSound;
-(BOOL) playPreparedAudiowithCompetitionBlock:(PlayerCompletitionBlock) playerCompletitionBlock;

-(BOOL) playData:(NSData*) audioData playerCompletitionBlock:(PlayerCompletitionBlock) playerCompletitionBlock;
-(void) pause;
-(BOOL) play;
@end
