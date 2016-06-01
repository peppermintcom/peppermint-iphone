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

@interface SpeechRecognitionService ()

@property (nonatomic, assign) BOOL streaming;
@property (nonatomic, strong) Speech *client;
@property (nonatomic, strong) GRXBufferedPipe *writer;
@property (nonatomic, strong) ProtoRPC *call;
@property (nonatomic, strong) TranscriptionModel *transcriptionModel;
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
    initialRecognizeRequest.interimResults = NO;
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
        [_writer finishWithError:nil];
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

- (void) transcriptAudioData:(NSData *) audioData withCompletion:(SpeechRecognitionNonStreamCompletionHandler)completion {
    RecognizeRequest *request = [RecognizeRequest message];
    
    if(!self.call) {
        NSLog(@"Canceling ProtoRPC call in transcriptAudioData. This can affect ongoing recording processes!!\n\nBE AWARE!!!\n\n");
        [self.call cancel];
    }
    
    Speech *client = [[Speech alloc] initWithHost:HOST];
    _writer = [[GRXBufferedPipe alloc] init];
    
    self.call = [client RPCToNonStreamingRecognizeWithRequest:request
                                                      handler:^(NonStreamingRecognizeResponse *response, NSError *error) {
                                                          completion(response, error);
                                                      }];
    
    self.call.requestHeaders[XGoogApiKey] = GOOGLE_SPEECH_API_KEY;
    [self.call start];
    request.initialRequest = [self initialRecognizeRequest];
    
    AudioRequest *audioRequest = [AudioRequest message];
    audioRequest.content = audioData;
    request.audioRequest = audioRequest;
    
    [_writer writeValue:request];
}

@end
