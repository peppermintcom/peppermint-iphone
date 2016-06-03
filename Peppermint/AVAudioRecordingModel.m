//
//  AVAudioRecordingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 20/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "AVAudioRecordingModel.h"
#import "RecordingModel_Addition.h"

@implementation AVAudioRecordingModel {
    AVAudioRecorder *recorder;
}

-(void) initRecorder {
    if(!recorder) {
        if([self setAudioSession:YES]) {
            NSError *error;
            NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                           [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                                           [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                           [NSNumber numberWithFloat:AUDIO_SAMPLE_RATE], AVSampleRateKey,
                                           nil];
            
            recorder = [[AVAudioRecorder alloc] initWithURL:self.fileUrl settings:recordSetting error:&error];
            if(error) {
                [self.delegate operationFailure:error];
            } else {
                recorder.delegate = self;
                [[AudioSessionModel sharedInstance] attachAVAudioProcessObject:recorder];
            }
        }
    } else {
        NSLog(@"Recorder was already active!!!");
    }
}

-(void) record {
    if(!recorder.recording) {
        if([recorder prepareToRecord] && [recorder record]) {
            recorder.meteringEnabled = [self.delegate respondsToSelector:@selector(meteringUpdatedWithAverage:andPeak:)];
            [super record];
        } else {
            [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not start record", @"Error message") code:0 userInfo:nil]];
        }
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Recording is already active", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) pause {
    if(recorder.recording) {
        [super pause];
        [recorder pause];
        [self setAudioSession:NO];
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Recording is not active", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) resume {
    if(![recorder record]) {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not resume", @"Error message") code:0 userInfo:nil]];
    } else {
        [super resume];
    }
}

-(void) stop {
    [super stop];
    [recorder stop];
    [self setAudioSession:NO];
}

-(NSTimeInterval) currentRecordingTime {
    return recorder.currentTime;
}

#pragma mark - Metering

-(void)updateMetering {
    if([self.delegate respondsToSelector:@selector(meteringUpdatedWithAverage:andPeak:)]) {
        [recorder updateMeters];
        CGFloat average = [recorder averagePowerForChannel:0];
        CGFloat peak    = [recorder peakPowerForChannel:0];
        [self.delegate meteringUpdatedWithAverage:average andPeak:peak];
        recorder.meteringEnabled = YES;
    }
}

#pragma mark - BackUp

-(void) backUpRecording {
    CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
    [RecordingModel setPreviousFileLength:recorder.currentTime + previousFileLength];
    [self stop];
    [self copyFileFrom:self.fileUrl targetUrl:[self backUpFileUrl] completion:nil];
}

@end
