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
    NSTimer *timer;
    NSDate *pauseStart, *previousFireDate;
    __block NSTimeInterval previousMeasurement;
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
            previousMeasurement = 0;
            timer = [NSTimer scheduledTimerWithTimeInterval:PING_INTERVAL target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
        } else {
            [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not start record", @"Error message") code:0 userInfo:nil]];
        }
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Recording is already active", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) pause {
    if(recorder.recording) {
        [self pauseTimer];
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
        [self resumeTimer];
    }
}

-(void) stop {
    [timer invalidate];
    timer = nil;
    [recorder stop];
    [self setAudioSession:NO];
}

#pragma mark - Recording Timer (Pause/Resume Timer)

-(void) pauseTimer {
    pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    previousFireDate = [timer fireDate];
    [timer setFireDate:[NSDate distantFuture]];
}

-(void) resumeTimer {
    float pauseTime = -1*[pauseStart timeIntervalSinceNow];
    [timer setFireDate:[previousFireDate initWithTimeInterval:pauseTime sinceDate:previousFireDate]];
    pauseStart = previousFireDate = nil;
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

-(void)onTick:(NSTimer *)timer {
    [self updateMetering];
    CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
    
    NSTimeInterval diff = fabs(recorder.currentTime - previousMeasurement);
    BOOL isDiffValid = (diff < PING_INTERVAL * 100 && recorder.currentTime >= -0.00001);
    BOOL didGetReset = !isDiffValid && (recorder.currentTime > 0 && recorder.currentTime < PING_INTERVAL);
    
    if(isDiffValid || didGetReset) {
        previousMeasurement = recorder.currentTime;
        [self.delegate timerUpdated:recorder.currentTime + previousFileLength];
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
