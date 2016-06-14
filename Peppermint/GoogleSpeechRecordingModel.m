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

#define SPEECH_BUFFER               32768 //16384

@interface GoogleSpeechRecordingModel() <AudioControllerDelegate, AACFileWriterDelegate>
@property (nonatomic, strong) NSMutableData *audioData;
@property (nonatomic, strong) AACFileWriter *aacFileWriter;

@property (atomic, assign) BOOL isFileConversionCompleted;
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
        self.isActive = YES;
        self.gotError = NO;
        [[AudioSessionModel sharedInstance] attachAVAudioProcessObject:self];
        self.audioController = [AudioController new];
        self.audioController.delegate = self;
        [self.audioController prepare];
        self.speechRecognitionService = [SpeechRecognitionService new];
    } else {
        NSLog(@"Could not activate audio session.");
    }
}

-(void) record {
    NSLog(@"Record is called.....");
    self.isActive = YES;
    self.receivedPrepareMessage = NO;
    self.isFileConversionCompleted = NO;
    self.isTranscriptionCompleted = NO;
    self.isStopCommandReceived = NO;
    self.aacFileWriter = [AACFileWriter new];
    self.aacFileWriter.delegate = self;
    self.transcriptionInfo = nil;
    self.audioData = [[NSMutableData alloc] init];
    [self.speechRecognitionService prepareToStream];
    [self processSampleData:[NSData new]];
    [self.audioController start];
    [super record];
}

-(void) pause {
    NSLog(@"Pause is not implemented. Stopping the message.");
    [self stop];
}

-(void) resume {
    NSLog(@"Resume is not implemented. Starting recording.");
    [self record];
}

-(void) stop {
    if (self.isStopCommandReceived) {
        NSLog(@"Not processing stop again, because isStopCommandReceived = YES");
    } else {
        [super stop];
        self.isStopCommandReceived = YES;
        [self.speechRecognitionService stopStreaming];
        [self.audioController stop];
        [self completeAudioSession];
    }
}

#pragma mark - Metering

-(void)updateMetering {
#warning "Measure metering if possible"
}

-(void) operationFailure:(NSError *)error {
#warning "Check operations occuring during failure"
    NSLog(@"GoogleSpeechRecordingModel got error:%@", error);
    [self stop];
    self.gotError = YES;
    [self completeAudioSession];
    [self.delegate operationFailure:error];
}

-(void) errorInTranscriptionResponse:(NSError*) error {
    NSLog(@"Failure in transcription.\n%@", error);
    self.gotError = YES;
    [self.speechRecognitionService stopStreamingWithError:error];
    self.speechRecognitionService = nil;
    [self speechResponseDidNotReceivedInTime];
}

- (void) processSampleData:(NSData *)data {
    [self.aacFileWriter appendData:data];
    self.transcriptionInfo.rawAudioData = [self.aacFileWriter.audioData copy];
    [self.audioData appendData:data];
    
    NSInteger frameCount = [data length] / 2;
    int16_t *samples = (int16_t *) [data bytes];
    int64_t sum = 0;
    for (int i = 0; i < frameCount; i++) {
        sum += abs(samples[i]);
    }
    NSLog(@"audio %d %d", (int) frameCount, (int) (sum * 1.0 / frameCount));
    
    if(self.gotError) {
        NSLog(@"Not sending, becase an error occured in previous sending.");
    } else if (!self.speechRecognitionService.isStreaming || [self.audioData length] > SPEECH_BUFFER) {
        NSLog(@"SENDING, bytes length:%5ld", self.audioData.length);
        weakself_create();
        [self setSpeechResponseWaitTimer];
        [self.speechRecognitionService
         streamAudioData:self.audioData
         withCompletion:^(RecognizeResponse *response, NSError *error) {
             NSLog(@"RESPONSE RECEIVED");
             [weakSelf.speechResponseWaitTimer invalidate];
             if(!self.speechResponseWaitTimer) {
                 NSLog(@"Not processing response because speechResponseWaitTimer is fired earlier.");
                 NSLog(@"Response:\n%@\nerror:\n%@", response, error);
                 NSLog(@"---- End of non processed response information ----");
             } else if (error) {
                 [weakSelf errorInTranscriptionResponse:error];
             } else if(!response) {
                 NSLog(@"Got finished signal");
                 weakSelf.isTranscriptionCompleted = YES;
                 [weakSelf checkToFinishRecordingAndCallDelegate];
             } else if (response.error.code > 0 && response.error.message.length > 0) {
                 NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           @"message", response.error.message,
                                           nil];
                 NSError *responseError = [NSError errorWithDomain:DOMAIN_GRPC
                                                              code:response.error.code
                                                          userInfo:userInfo];
                 [weakSelf errorInTranscriptionResponse:responseError];
             } else {
                 weakSelf.isTranscriptionCompleted = NO;
                 [weakSelf.transcriptionInfo processRecogniseResponse:response];
             }
         }];
        self.audioData = [[NSMutableData alloc] init];
    }
}

-(void) prepareRecordData {
    if(!self.isStopCommandReceived) {
        NSLog(@"Stop command is not received yet. Can not prepareRecordData");
    } else {
        self.receivedPrepareMessage = YES;
        [self startFileConversion];
    }
}

-(void) startFileConversion {
    if([self setAudioSession:YES]) {
        self.isActive = YES;
        [self.aacFileWriter convertToAACWithAudioStreamBasicDescription:self.audioController.asbd andFileUrl:self.fileUrl];
    } else {
        NSLog(@"Could not activate audio session.");
    }
}

#pragma mark - SeechResponseWaitTimer

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
    if(self.transcriptionInfo.text.length > 0) {
        self.transcriptionInfo.text = [self.transcriptionInfo.text stringByAppendingString:@" ..."];
    }
    [self checkToFinishRecordingAndCallDelegate];
}

#pragma mark - AACFileWriterDelegate

-(void) fileConversionIsFinished {
    [self completeAudioSession];
    self.isFileConversionCompleted = YES;
    [self checkToFinishRecordingAndCallDelegate];
    BOOL isForBackUp = (!self.receivedPrepareMessage);
    if(isForBackUp) {
        [self copyFileFrom:self.fileUrl targetUrl:[self backUpFileUrl] completion:nil];
    }
}

-(void) checkToFinishRecordingAndCallDelegate {
    if(self.receivedPrepareMessage && self.isFileConversionCompleted && self.isTranscriptionCompleted && self.isStopCommandReceived) {
        [super prepareRecordData];
    } else {
        NSLog(@"GoogleSpeechRecordingModel is strill processing");
    }
}

-(void) completeAudioSession {
    self.isActive = NO;
    [self setAudioSession:NO];
}

#pragma mark - BackUp

-(void) backUpRecording {
#warning "Implement back-up support"
    //CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
    //[RecordingModel setPreviousFileLength:self.currentRecordingTime + previousFileLength];
    [self stop];
    //[self startFileConversion];
}

@end
