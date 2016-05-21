//
//  RecordingModel_Addition.h
//  Peppermint
//
//  Created by Okan Kurtulus on 21/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "RecordingModel.h"
#import "AudioSessionModel.h"

#define DEFAULT_GAIN    0.8 //Input Gain must be a value btw 0.0 - 1.0
#define SAMPLE_RATE     16000.0   //44100 -> 44.1kHz = 44100, 16 kHz -> 16000

@interface RecordingModel (RecordingModel_Addition)

#pragma mark - Private functions used in subclasses
-(void) prepareRecordData;
-(BOOL) setAudioSession:(BOOL) active;
-(NSURL*) recordFileUrl;
-(NSURL*) backUpFileUrl;
-(void) copyFileFrom:(NSURL*)sourceUrl targetUrl:(NSURL*)targetUrl completion:(void(^)(void))completion;

@end
