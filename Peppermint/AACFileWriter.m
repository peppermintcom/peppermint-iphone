//
//  AACFileWriter.m
//  Speech
//
//  Created by Okan Kurtulus on 19/05/16.
//  Copyright © 2016 Google. All rights reserved.
//

#import "AACFileWriter.h"
#import <AVFoundation/AVFoundation.h>

@implementation AACFileWriter {
    TPAACAudioConverter *tPAACAudioConverter;
    BOOL isConverting;
}

-(id) init {
    self = [super init];
    if(self) {
        _audioData = [NSMutableData new];
        tPAACAudioConverter = nil;
        isConverting = NO;
    }
    return self;
}

-(void) appendData:(NSData*)data {
    if(_audioData) {
        [_audioData appendData:data];
    }
}

-(void) convertToAACWithAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd andFileUrl:(NSURL*)fileUrl {
    NSUInteger length = self.audioData.length;
    if(length == 0) {
        NSLog(@"AudioData is empty. Nothing to convert for AAC");
    } else if (isConverting) {
        NSLog(@"There is an ongoing conversion. Not handling this request.");
    } else {
        isConverting = YES;
        [self performConversionWithAudioStreamBasicDescription:asbd andFileUrl:fileUrl];
    }
}

-(void) performConversionWithAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd andFileUrl:(NSURL*)fileUrl {
    NSString *destination = fileUrl.path;
    NSLog(@"Converting total bytes %ld to path %@", self.audioData.length, destination);    
    
    // Register an Audio Session interruption listener, important for AAC conversion
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    NSLog(@"Destination is %@", destination);
    tPAACAudioConverter = [[TPAACAudioConverter alloc] initWithDelegate:self
                                                             dataSource:self
                                                            audioFormat:asbd
                                                            destination:destination];
    [tPAACAudioConverter start];
}

#pragma mark - TPAACAudioConverterDelegate

- (void)AACAudioConverterDidFinishConversion:(TPAACAudioConverter*)converter {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object: nil];
    isConverting = NO;
    NSLog(@"AACAudioConverterDidFinishConversion:");
    [self.delegate fileConversionIsFinished];
}

- (void)AACAudioConverter:(TPAACAudioConverter*)converter didFailWithError:(NSError*)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object: nil];
    isConverting = NO;
    NSLog(@"Error occured: %@", error);
    [self.delegate operationFailure:error];
}

- (void)AACAudioConverter:(TPAACAudioConverter*)converter didMakeProgress:(CGFloat)progress {
    NSLog(@"DidMakeProgress:%.2f / 100", progress);
}

#pragma mark - Audio session interruption

- (void)audioSessionInterrupted:(NSNotification*)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if ( type == AVAudioSessionInterruptionTypeEnded) {
        //Checking the session state as below can be helpful!
        //if ( [self setAudioSession:YES] && tPAACAudioConverter ) {
            [tPAACAudioConverter resume];
        //}
    } else if ( type == AVAudioSessionInterruptionTypeBegan ) {
        if ( tPAACAudioConverter ) [tPAACAudioConverter interrupt];
    }
}

#pragma mark - TPAACAudioConverterDataSource

- (void)AACAudioConverter:(TPAACAudioConverter*)converter nextBytes:(char*)bytes length:(NSUInteger*)length {
    
    NSUInteger expectedLength = *length;
    NSUInteger audioDataLenth = self.audioData.length;
    
    if(expectedLength > audioDataLenth) {
        *length = audioDataLenth;
        [self.audioData getBytes:bytes length:audioDataLenth];
        [self.audioData replaceBytesInRange:NSMakeRange(0, audioDataLenth) withBytes:NULL length:0];
    } else {
        [self.audioData getBytes:bytes length:expectedLength];
        [self.audioData replaceBytesInRange:NSMakeRange(0, expectedLength) withBytes:NULL length:0];
    }
}

//optional
//- (void)AACAudioConverter:(TPAACAudioConverter *)converter seekToPosition:(NSUInteger)position {}

@end
