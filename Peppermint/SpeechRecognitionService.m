//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "SpeechRecognitionService.h"

#import <GRPCClient/GRPCCall.h>
#import <RxLibrary/GRXBufferedPipe.h>
#import <ProtoRPC/ProtoRPC.h>

#import "TranscriptionModel.h"

#define HOST            @"speech.googleapis.com"
#define XGoogApiKey     @"X-Goog-Api-Key"

#define NON_STREAM_COMPLETION      @"NonStreamCompletion"
#define STREAM_COMPLETION          @"StreamCompletion"

@interface SpeechRecognitionService ()

@property (nonatomic, assign) BOOL streaming;
@property (nonatomic, strong) Speech *client;
@property (nonatomic, strong) GRXBufferedPipe *writer;
@property (nonatomic, strong) ProtoRPC *call;
@property (nonatomic, strong) TranscriptionModel *transcriptionModel;
@property (strong, nonatomic) NSTimer *speechResponseWaitTimer;
@end

@implementation SpeechRecognitionService

-(id) init {
    self = [super init];
    if(self) {
        self.transcriptionModel = [TranscriptionModel new];
    }
    return self;
}

-(InitialRecognizeRequest*) initialRecognizeRequest {
    InitialRecognizeRequest *initialRecognizeRequest = [InitialRecognizeRequest message];
    initialRecognizeRequest.encoding = InitialRecognizeRequest_AudioEncoding_Linear16;
    initialRecognizeRequest.sampleRate = AUDIO_SAMPLE_RATE;
    initialRecognizeRequest.languageCode = [self.transcriptionModel transctiptionLanguageCode];
    initialRecognizeRequest.maxAlternatives = 1;
    initialRecognizeRequest.profanityFilter = YES;
    initialRecognizeRequest.continuous = YES;
    initialRecognizeRequest.interimResults = YES;
    initialRecognizeRequest.enableEndpointerEvents = YES;
    return initialRecognizeRequest;
}

-(void) prepareToStream {
    [self stopStreaming];
    if(self.call) {
        NSLog(@"Canceling ProtoRPC call in transcriptAudioData. This can affect ongoing recording processes!!\n\nBE AWARE!!!\n\n");
        [self.call cancel];
    }
}

- (void) streamAudioData:(NSData *) audioData withCompletion:(SpeechRecognitionCompletionHandler)completion {
  RecognizeRequest *request = [RecognizeRequest message];
  if (!self.streaming) {
    _client = [[Speech alloc] initWithHost:HOST];
    _writer = [[GRXBufferedPipe alloc] init];
    self.call = [self.client RPCToRecognizeWithRequestsWriter:_writer
                                         eventHandler:^(BOOL done, RecognizeResponse *response, NSError *error) {
                                           completion(response, error);
                                         }];
    self.call.requestHeaders[XGoogApiKey] = GOOGLE_SPEECH_API_KEY;
    [self.call start];
    self.streaming = YES;
    request.initialRequest = [self initialRecognizeRequest];
  }

  AudioRequest *audioRequest = [AudioRequest message];
  audioRequest.content = audioData;
  request.audioRequest = audioRequest;

  [_writer writeValue:request];
}

- (void) stopStreamingWithError:(NSError*) error {
    if(_streaming) {
        [_writer finishWithError:error];
        _streaming = NO;
        NSLog(@"stopStreaming is processed and streaming is completed");
    } else {
        NSLog(@"stopStreaming is called in non-streaming state.");
    }
}

- (void) stopStreaming {
    [self stopStreamingWithError:nil];
}

- (BOOL) isStreaming {
  return _streaming;
}

- (void) transcriptAudioData:(NSData *) audioData ofDuration:(NSInteger)duration withCompletion:(SpeechRecognitionNonStreamCompletionHandler)completion {
    AudioRequest *audioRequest = [AudioRequest message];
    audioRequest.content = audioData;
    
    RecognizeRequest *request = [RecognizeRequest message];
    request.initialRequest = [self initialRecognizeRequest];
    request.audioRequest = audioRequest;
    Speech *client = [[Speech alloc] initWithHost:HOST];
    
    weakself_create();
    NSInteger timeout = MIN(150, (duration * 2.5));
    [self setSpeechResponseWaitTimerWithUserInfo:@{NON_STREAM_COMPLETION : completion} timeout:timeout];
    ProtoRPC *call = [client RPCToNonStreamingRecognizeWithRequest:request
                                                           handler:^(NonStreamingRecognizeResponse *response, NSError *error) {
                                                               NSLog(@"Got response:\n%@", response);
                                                               strongSelf_create()
                                                               if(strongSelf) {
                                                                   BOOL isTimerInvalidated = [strongSelf invalidateSpeechResponseWaitTimer];
                                                                   if(isTimerInvalidated) {
                                                                       completion(response, error);
                                                                   } else {
                                                                       NSLog(@"Received response after timeout. Consider to increase timeout limit.");
                                                                   }
                                                               }
                                                           }];
    call.requestHeaders[XGoogApiKey] = GOOGLE_SPEECH_API_KEY;
    [call start];
}

#pragma mark - SpeechResponseWaitTimer

-(BOOL) invalidateSpeechResponseWaitTimer {
    BOOL result = NO;
    if(_speechResponseWaitTimer ) {
        [self.speechResponseWaitTimer invalidate];
        self.speechResponseWaitTimer = nil;
        NSLog(@"Timer is invalidated.");
        result = YES;
    } else {
        NSLog(@"Timer is not working. Clean to go...");
    }
    return result;
}

-(void) setSpeechResponseWaitTimerWithUserInfo:(NSDictionary*) userInfo timeout:(NSInteger)timeout {
    [self invalidateSpeechResponseWaitTimer];
    self.speechResponseWaitTimer = [NSTimer scheduledTimerWithTimeInterval:timeout > 0 ? timeout : SPEECH_RESPONSE_WAIT_TIME
                                                                    target:self
                                                                  selector:@selector(timeOutOccuredWithTimer:)
                                                                  userInfo:userInfo
                                                                   repeats:NO];
    NSLog(@"Timer is set to %ld seconds with %@", timeout, userInfo.description);
}

-(void) timeOutOccuredWithTimer:(NSTimer*) timer {
    NSLog(@"timeOutOccuredWithTimer: is called");
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"timoutOccured"};
    NSError *error = [NSError errorWithDomain:DOMAIN_GRPC code:ERROR_CODE_TIMEOUT userInfo:userInfo];
    
    userInfo = (NSDictionary*) timer.userInfo;
    if(!userInfo) {
        NSLog(@"timeOutOccuredWithTimer: parameter is invalid!");
    } else if([userInfo.allKeys containsObject:NON_STREAM_COMPLETION]) {
        SpeechRecognitionNonStreamCompletionHandler completion = (SpeechRecognitionNonStreamCompletionHandler)(userInfo[NON_STREAM_COMPLETION]);
        completion(nil, error);
    } else if ([userInfo.allKeys containsObject:STREAM_COMPLETION]) {
        SpeechRecognitionCompletionHandler completion = (SpeechRecognitionCompletionHandler)(userInfo[STREAM_COMPLETION]);
        completion(nil, error);
    } else {
        NSLog(@"Timeout event is not handled!!!");
    }
}

-(void) dealloc {
    NSLog(@"dealloc Speech Recognition service...");
    if(self.call) {
        [self.call cancel];
    }
}
@end
