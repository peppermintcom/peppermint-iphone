//
//  GoogleSpeechRecordingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 20/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "GoogleSpeechRecordingModel.h"
#import "RecordingModel_Addition.h"

#import "AudioController.h"
#import "AACFileWriter.h"
#import "SpeechRecognitionService.h"

#define SPEECH_BUFFER   16384

@interface GoogleSpeechRecordingModel() <AudioControllerDelegate, AACFileWriterDelegate>
@property (nonatomic, strong) NSMutableData *audioData;
@property (nonatomic, strong) AACFileWriter *aacFileWriter;
@property (nonatomic, strong) NSDate *recordingStartDate;

@property (atomic, assign) BOOL receivedPrepareMessage;
@property (atomic, assign) BOOL isTranscriptionCompleted;
@property (atomic, assign) BOOL isStopCommandReceived;

@end

@implementation GoogleSpeechRecordingModel

-(void) initRecorder {    
    if([self setAudioSession:YES]) {
        AudioController *audioController = [AudioController sharedInstance];
        audioController.delegate = self;
        [audioController stop];
        [audioController prepare];
        self.isActive = YES;
        [[AudioSessionModel sharedInstance] attachAVAudioProcessObject:self];
    } else {
        NSLog(@"Could not activate audio session.");
    }
}

-(void) record {
    NSLog(@"Record is called.....");
    self.receivedPrepareMessage = NO;
    self.isTranscriptionCompleted = NO;
    self.isStopCommandReceived = NO;
    _recordingStartDate = nil;
    [self recordingStartDate];
    self.aacFileWriter = [AACFileWriter new];
    self.aacFileWriter.delegate = self;
    self.transcriptionText = @"";
    self.audioData = [[NSMutableData alloc] init];
    [[AudioController sharedInstance] start];
}

-(void) pause {
    NSLog(@"Pause is not implemented.");
}

-(void) resume {
    NSLog(@"Resume is not implemented.");
}

-(void) stop {
    NSLog(@"Stop is called.....");
    self.isStopCommandReceived = YES;
    [[AudioController sharedInstance] stop];
}

#pragma mark - Metering

-(void)updateMetering {
#warning "Measure metering if possible"
    CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
    NSTimeInterval recordingTime = [[NSDate new] timeIntervalSinceDate:self.recordingStartDate];
    [self.delegate timerUpdated:(recordingTime + previousFileLength)];
}

-(void) operationFailure:(NSError *)error {
    [self stop];
    [[SpeechRecognitionService sharedInstance] stopStreaming];
    if(self.isActive) {
        [self.delegate operationFailure:error];
        self.isActive = NO;
    }
}

- (void) processSampleData:(NSData *)data {
    [self.aacFileWriter appendData:data];
    [self.audioData appendData:data];
    [self updateMetering];
    
    /*
    NSInteger frameCount = [data length] / 2;
    int16_t *samples = (int16_t *) [data bytes];
    int64_t sum = 0;
    for (int i = 0; i < frameCount; i++) {
        sum += abs(samples[i]);
    }
    //NSLog(@"audio %d %d", (int) frameCount, (int) (sum * 1.0 / frameCount));
    */
    
    if ([self.audioData length] > SPEECH_BUFFER) {
        NSLog(@"SENDING");
        weakself_create();
        [[SpeechRecognitionService sharedInstance] streamAudioData:self.audioData
                                                    withCompletion:^(RecognizeResponse *response, NSError *error) {
                                                        NSLog(@"RESPONSE RECEIVED");
                                                        if (error) {
                                                            [weakSelf operationFailure:error];
                                                        } else if(!response) {
                                                            NSLog(@"There is no response information. End of recognising.");
                                                            weakSelf.isTranscriptionCompleted = YES;
                                                        } else {
                                                            weakSelf.isTranscriptionCompleted = NO;
                                                            NSLog(@"RESPONSE: %@", response);
                                                            for (SpeechRecognitionResult *result in response.resultsArray) {
                                                                if(result.alternativesArray.count > 0) {
                                                                    SpeechRecognitionAlternative *alternative = result.alternativesArray.firstObject;
                                                                    weakSelf.transcriptionText = [weakSelf.transcriptionText stringByAppendingString:alternative.transcript];
                                                                    weakSelf.transcriptionConfidence = [NSNumber numberWithFloat:alternative.confidence];
                                                                }                                                            }
                                                        }
                                                        
                                                        if (weakSelf.isTranscriptionCompleted) {
                                                            NSLog(@"Got finished signal");
                                                            [[SpeechRecognitionService sharedInstance] stopStreaming];
                                                            [weakSelf checkToFinishRecordingAndCallDelegate];
                                                        }
                                                    }];
        self.audioData = [[NSMutableData alloc] init];
    }
}

-(void) prepareRecordData {
    [self stop];
    NSURL *fileUrl = [self recordFileUrl];
    [self.aacFileWriter convertToAACWithAudioStreamBasicDescription:[AudioController sharedInstance].asbd andFileUrl:fileUrl];
}

#pragma mark - AACFileWriterDelegate

-(void) fileConversionIsFinished {
    self.receivedPrepareMessage = YES;
    [self checkToFinishRecordingAndCallDelegate];
}

-(void) checkToFinishRecordingAndCallDelegate {
    if(self.receivedPrepareMessage && self.isTranscriptionCompleted && self.isStopCommandReceived) {
        self.isActive = NO;
        [self setAudioSession:NO];
        [super prepareRecordData];
    } else {
        NSLog(@"GoogleSpeechRecordingModel is strill processing");
    }
}

-(NSDate*) recordingStartDate {
    if(!_recordingStartDate) {
        _recordingStartDate = [NSDate new];
    }
    return _recordingStartDate;
}

#pragma mark - BackUp

-(void) backUpRecording {
    NSLog(@"backUpRecording is not supported");
}
@end
