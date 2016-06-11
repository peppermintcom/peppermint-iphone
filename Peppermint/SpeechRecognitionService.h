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

#import <Foundation/Foundation.h>
#import "google/cloud/speech/v1/CloudSpeech.pbrpc.h"

#define SPEECH_RESPONSE_WAIT_TIME   30
#define ERROR_CODE_TIMEOUT          -123

typedef void (^SpeechRecognitionCompletionHandler)(RecognizeResponse *object, NSError *error);
typedef void (^SpeechRecognitionNonStreamCompletionHandler)(NonStreamingRecognizeResponse *object, NSError *error);

@interface SpeechRecognitionService : NSObject

-(void) prepareToStream;
- (void) streamAudioData:(NSData *) audioData
          withCompletion:(SpeechRecognitionCompletionHandler)completion;
- (void) stopStreamingWithError:(NSError*) error;
- (void) stopStreaming;
- (BOOL) isStreaming;

- (void) transcriptAudioData:(NSData *) audioData withCompletion:(SpeechRecognitionNonStreamCompletionHandler)completion;

@end
