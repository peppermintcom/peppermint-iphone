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
#import "ConnectionModel.h"

#define SPEECH_BUFFER   16384
#define SPEECH_RESPONSE_WAIT_TIME   30

@interface GoogleSpeechRecordingModel() <AudioControllerDelegate, AACFileWriterDelegate>
@property (nonatomic, strong) NSMutableData *audioData;
@property (nonatomic, strong) AACFileWriter *aacFileWriter;
@property (nonatomic, strong) NSDate *recordingStartDate;

@property (atomic, assign) BOOL receivedPrepareMessage;
@property (atomic, assign) BOOL isTranscriptionCompleted;
@property (atomic, assign) BOOL isStopCommandReceived;

@property (strong, nonatomic) AudioController *audioController;
@property (strong, nonatomic) SpeechRecognitionService *speechRecognitionService;

@property (atomic, assign) BOOL gotError;

@property (strong, nonatomic) NSTimer *speechResponseWaitTimer;
@end

typedef enum : NSUInteger {
    OK,
    CANCELLED,
    UNKNOWN,
    INVALID_ARGUMENT,
    DEADLINE_EXCEEDED,
    NOT_FOUND,
    ALREADY_EXISTS,
    PERMISSION_DENIED,
    UNAUTHENTICATED,
    RESOURCE_EXHAUSTED,
    FAILED_PRECONDITION,
    ABORTED,
    OUT_OF_RANGE,
    UNIMPLEMENTED,
    INTERNAL,
    UNAVAILABLE,
    DATA_LOSS,
} GrpcErrorCode;

@implementation GoogleSpeechRecordingModel

-(void) initRecorder {    
    if([self setAudioSession:YES]) {
        self.audioController = [AudioController new];
        self.audioController.delegate = self;
        [self.audioController prepare];
        self.speechRecognitionService = [SpeechRecognitionService new];
        self.isActive = YES;
        self.gotError = NO;
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
    [self.audioController start];
}

-(void) pause {
    NSLog(@"Pause is not implemented.");
}

-(void) resume {
    NSLog(@"Resume is not implemented.");
}

-(void) stop {
    if(self.gotError) {
        NSLog(@"Not stopping cos already got error.");
    } else if (self.isStopCommandReceived) {
        NSLog(@"Not processing stop again, because isStopCommandReceived = NO");
    } else {
        self.isStopCommandReceived = YES;
        [self.audioController stop];
        [self.speechRecognitionService stopStreaming];
    }
}

#pragma mark - Metering

-(void)updateMetering {
#warning "Measure metering if possible"
    CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
    NSTimeInterval recordingTime = [[NSDate new] timeIntervalSinceDate:self.recordingStartDate];
    [self.delegate timerUpdated:(recordingTime + previousFileLength)];
}

-(void) operationFailure:(NSError *)error {
    NSLog(@"GoogleSpeechRecordingModel got error:%@", error);
    [self stop];
    self.gotError = YES;
    [self completeAudioSession];
    [self.delegate operationFailure:error];
}

- (void) processSampleData:(NSData *)data {
    [self.aacFileWriter appendData:data];
    [self.audioData appendData:data];
    [self updateMetering];
    
    if(![[ConnectionModel sharedInstance] isInternetReachable]) {
        NSLog(@"Internet connection is not active.");
        NSError *error = [NSError errorWithDomain:DOMAIN_GOOGLESPEECHRECORDINGMODEL
                                           code:CODE_NO_CONNECTION
                                         userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Info", @"No internet connection", nil]];
        [self operationFailure:error];
        self.isTranscriptionCompleted = YES;
    } else if(self.gotError) {
        NSLog(@"Not sending, becase an error occured in previous sending.");
    } else if ([self.audioData length] > SPEECH_BUFFER) {
        NSLog(@"SENDING");
        weakself_create();
        [self setSpeechResponseWaitTimer];
        [self.speechRecognitionService streamAudioData:self.audioData
                                                    withCompletion:^(RecognizeResponse *response, NSError *error) {
                                                        NSLog(@"RESPONSE RECEIVED");
                                                        [weakSelf.speechResponseWaitTimer invalidate];
                                                        if(!self.speechResponseWaitTimer) {
                                                            NSLog(@"Not processing response because speechResponseWaitTimer is fired earlier.");
                                                            NSLog(@"Response:\n%@\nerror:\n%@", response, error);
                                                            NSLog(@"---- End of non processed response information ----");
                                                        } else if (error) {
                                                            [weakSelf operationFailure:error];
                                                        } else if(!response) {
                                                            NSLog(@"Got finished signal");
                                                            weakSelf.isTranscriptionCompleted = YES;
                                                            [weakSelf checkToFinishRecordingAndCallDelegate];
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
                                                    }];
        self.audioData = [[NSMutableData alloc] init];
    }
}

-(void) prepareRecordData {
    if(self.speechRecognitionService.isStreaming) {
        NSLog(@"SpeechRecognitionService is still streaming. Can not prepareRecordData");
    } else {
        NSURL *fileUrl = [self recordFileUrl];
        [self.aacFileWriter convertToAACWithAudioStreamBasicDescription:self.audioController.asbd andFileUrl:fileUrl];
    }
}

#pragma mark - 

-(void) setSpeechResponseWaitTimer {
    [self.speechResponseWaitTimer invalidate];
    self.speechResponseWaitTimer = [NSTimer scheduledTimerWithTimeInterval:SPEECH_RESPONSE_WAIT_TIME
                                                                    target:self
                                                                  selector:@selector(speechResponseDidNotReceivedInTime)
                                                                  userInfo:nil
                                                                   repeats:NO];
}

-(void) speechResponseDidNotReceivedInTime {
    self.speechResponseWaitTimer = nil;
    self.isTranscriptionCompleted = YES;
    [self checkToFinishRecordingAndCallDelegate];
}

#pragma mark - AACFileWriterDelegate

-(void) fileConversionIsFinished {
    self.receivedPrepareMessage = YES;
    [self checkToFinishRecordingAndCallDelegate];
}

-(void) checkToFinishRecordingAndCallDelegate {
    if(self.receivedPrepareMessage && self.isTranscriptionCompleted && self.isStopCommandReceived) {
        [self completeAudioSession];
        [super prepareRecordData];
    } else {
        NSLog(@"GoogleSpeechRecordingModel is strill processing");
    }
}

-(void) completeAudioSession {
    self.isActive = NO;
    [self setAudioSession:NO];
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
