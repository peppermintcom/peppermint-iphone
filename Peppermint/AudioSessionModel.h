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

+ (instancetype) sharedInstance;
-(void) attachAVAudioProcessObject:(id)item;
-(BOOL) updateSessionState:(BOOL) destinationSessionState;
-(BOOL) isAudioSessionActive;

@end
