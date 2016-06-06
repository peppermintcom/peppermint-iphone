//
//  TranscriptionInfo.m
//  Peppermint
//
//  Created by Okan Kurtulus on 06/06/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "TranscriptionInfo.h"
#import "google/cloud/speech/v1/CloudSpeech.pbrpc.h"

@interface TranscriptionInfo()
@property (assign, atomic) BOOL gotAtLeastOnePieceOfFinalTranscription;
@end

@implementation TranscriptionInfo

-(id) init {
    self = [super init];
    if(self) {
        self.gotAtLeastOnePieceOfFinalTranscription = NO;
    }
    return self;
}

-(void) processRecogniseResponse:(RecognizeResponse*) response {
    NSLog(@"RESPONSE: %@", response);
    if(!self.gotAtLeastOnePieceOfFinalTranscription) {
        self.text = nil;
    }
    for (SpeechRecognitionResult *result in response.resultsArray) {
        if (result.alternativesArray.count > 0) {
            if(self.gotAtLeastOnePieceOfFinalTranscription && !result.isFinal) {
                NSLog(@"Not processing response.");
            } else {
                self.gotAtLeastOnePieceOfFinalTranscription |= result.isFinal;
                SpeechRecognitionAlternative *alternative = result.alternativesArray.firstObject;
                NSString *baseString = (self.text ? self.text : @"");
                self.text = [baseString stringByAppendingString:alternative.transcript];
                self.confidence = [NSNumber numberWithFloat:alternative.confidence];
            }
        }
    }
}

@end
