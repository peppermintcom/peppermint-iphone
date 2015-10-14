//
//  RecordingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingModel.h"

#define DEFAULT_GAIN 0.8 //Input Gain must be a value btw 0.0 - 1.0

@implementation RecordingModel {
    AVAudioRecorder *recorder;
    NSTimer *timer;
}

-(id) init {
    self = [super init];
    if(self) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        } else {            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            __weak RecordingModel *weakSelf = self;
            if([session respondsToSelector:@selector(requestRecordPermission:)]) {
                [session requestRecordPermission:^(BOOL granted) {
                    self.grantedForMicrophone = granted;
                    if(granted) {
                        [weakSelf performGrantedOperations];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate accessRightsAreSupplied];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate microphoneAccessRightsAreNotSupplied];
                        });
                    }
                }];
            } else {
                [weakSelf performGrantedOperations];
            }
        }
    }
    return self;
}

-(void) performGrantedOperations {
    [self initRecordFile];
    [self initRecorder];
    [self setInputGain];
}

- (void) dealloc {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:self.fileUrl error:&error];
    if(error) {
        [self.delegate operationFailure:error];
    }
}

-(void) initRecordFile {
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"PeppermintMessage.m4a", nil];
    self.fileUrl = [NSURL fileURLWithPathComponents:pathComponents];
}

-(void) initRecorder {
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    recorder = [[AVAudioRecorder alloc] initWithURL:self.fileUrl settings:recordSetting error:nil];
    recorder.delegate = self;    
    [recorder prepareToRecord];
}

-(void) setInputGain {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError* error;
    if(session.isInputGainSettable) {
        [session setInputGain:DEFAULT_GAIN error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        }
    } else {
        NSLog(@"input gain is not settable. Using default value : %f", session.inputGain);
    }
}

-(void) record {
    if(!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        [session setCategory:AVAudioSessionCategoryRecord error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        } else {
            [session setActive:YES error:nil];
            if(![recorder record]) {
                [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not start record", @"Error message") code:0 userInfo:nil]];
            } else {
                timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
            }
        }
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Recording is already acitve", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) pause {
    if(recorder.recording) {
        [recorder pause];
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Recording is not acitve", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) resume {
    if(![recorder record]) {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not resume", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) stop {
    [timer invalidate];
    timer = nil;
    [recorder stop];    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) {
        [self.delegate operationFailure:error];
    }
}

-(NSTimeInterval) recordingTime {
    return recorder.currentTime;
}

-(void)onTick:(NSTimer *)timer {
    [self.delegate timerUpdated:recorder.currentTime];
}

@end
