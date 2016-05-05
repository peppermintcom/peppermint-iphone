//
//  AVAudioPlayer_Addition.h
//  Peppermint
//
//  Created by Okan Kurtulus on 05/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAudioPlayer (AVAudioPlayer_Addition)
-(void)fadeVolumeInToLevel:(NSNumber*)finalLevel;
-(void)fadeVolumeOut;

@end
