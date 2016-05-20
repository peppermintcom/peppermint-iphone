//
//  GoogleSpeechModel.m
//  Speech
//
//  Created by Okan Kurtulus on 20/05/16.
//  Copyright © 2016 Google. All rights reserved.
//

#import "GoogleSpeechModel.h"
#import <AVFoundation/AVFoundation.h>

#import "AudioController.h"
#import "SpeechRecognitionService.h"
#import "google/cloud/speech/v1/CloudSpeech.pbrpc.h"
#import "AACFileWriter.h"

@interface GoogleSpeechModel () <AudioControllerDelegate>
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSMutableData *audioData;
@property (nonatomic, strong) AACFileWriter *aacFileWriter;
@end

@implementation GoogleSpeechModel

-(id) init {
    self = [super init];
    if(self) {
        [AudioController sharedInstance].delegate = self;
    }
    return self;
}

- (IBAction)recordAudio:(id)sender {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    _audioData = [[NSMutableData alloc] init];
    self.aacFileWriter = [AACFileWriter new];
    [[AudioController sharedInstance] prepare];
    [[AudioController sharedInstance] start];
}

- (IBAction)stopAudio:(id)sender {
    [[AudioController sharedInstance] stop];
    [[SpeechRecognitionService sharedInstance] stopStreaming];
    NSLog(@"Audio stopeed!");
    
    [self.aacFileWriter convertToAACWithAudioStreamBasicDescription:[AudioController sharedInstance].asbd];

}

- (void) processSampleData:(NSData *)data
{
    [self.aacFileWriter appendData:data];
    [self.audioData appendData:data];
    NSInteger frameCount = [data length] / 2;
    int16_t *samples = (int16_t *) [data bytes];
    int64_t sum = 0;
    for (int i = 0; i < frameCount; i++) {
        sum += abs(samples[i]);
    }
    //NSLog(@"audio %d %d", (int) frameCount, (int) (sum * 1.0 / frameCount));
    
    if ([self.audioData length] > 16384) {
        NSLog(@"SENDING");
        [[SpeechRecognitionService sharedInstance] streamAudioData:self.audioData
                                                    withCompletion:^(RecognizeResponse *response, NSError *error) {
                                                        if (response) {
                                                            BOOL finished = NO;
                                                            NSLog(@"RESPONSE RECEIVED");
                                                            if (error) {
                                                                NSLog(@"ERROR: %@", error);
                                                            } else {
                                                                NSLog(@"RESPONSE: %@", response);
                                                                for (SpeechRecognitionResult *result in response.resultsArray) {
                                                                    if (result.isFinal) {
                                                                        finished = YES;
                                                                    }
                                                                }
                                                                _textView.text = [response description];
                                                            }
                                                            if (finished) {
                                                                [self stopAudio:nil];
                                                            }
                                                        } else {
                                                            [self stopAudio:nil];
                                                        }
                                                    }];
        self.audioData = [[NSMutableData alloc] init];
    }
}

@end
