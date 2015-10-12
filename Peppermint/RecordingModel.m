//
//  RecordingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingModel.h"

@implementation RecordingModel {
    AVAudioRecorder *recorder;
    NSTimer *timer;
}

-(id) init {
    self = [super init];
    if(self) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        [session setCategory:AVAudioSessionCategoryRecord error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        } else {            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            if([session respondsToSelector:@selector(requestRecordPermission:)]) {
                [session requestRecordPermission:^(BOOL granted) {
                    self.grantedForMicrophone = granted;
                    if(granted) {
                        [self initRecordFile];
                        [self initRecorder];
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
                [self initRecordFile];
                [self initRecorder];
            }
        }
    }
    return self;
}

- (void)dealloc {
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
    recorder.meteringEnabled = YES;
}

-(void) record {
    if(!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        if(![recorder record]) {
            [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not start record", @"Error message") code:0 userInfo:nil]];
        } else {
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
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
}

-(NSTimeInterval) recordingTime {
    return recorder.currentTime;
}

-(void)onTick:(NSTimer *)timer {
    [self.delegate timerUpdated:recorder.currentTime];
}

@end
