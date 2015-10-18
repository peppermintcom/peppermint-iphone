//
//  RecordingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingModel.h"

#define DEFAULT_GAIN 0.8 //Input Gain must be a value btw 0.0 - 1.0

@implementation RecordingModel {
    AVAudioRecorder *recorder;
    NSTimer *timer;
}

-(id) init {
    self = [super init];
    if(self) {
        
        NSString *length = (NSString*) defaults_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH);
        self.previousFileLength = !length ? 0 : length.intValue;
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        } else {            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            __weak RecordingModel *weakSelf = self;
            if([session respondsToSelector:@selector(requestRecordPermission:)]) {
                [session requestRecordPermission:^(BOOL granted) {
                    self.grantedForMicrophone = granted;
                    if(granted) {
                        [weakSelf performGrantedOperations];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate accessRightsAreSupplied];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate microphoneAccessRightsAreNotSupplied];
                        });
                    }
                }];
            } else {
                [weakSelf performGrantedOperations];
            }
        }
    }
    return self;
}

-(void) performGrantedOperations {
    [self initRecordFile];
    [self initRecorder];
    [self setInputGain];
}

- (void) dealloc {
    [self removeFileIfExistsAtUrl:self.fileUrl];
}

-(void) initRecordFile {
    self.fileUrl = [self recordFileUrl];
}

-(void) initRecorder {
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    recorder = [[AVAudioRecorder alloc] initWithURL:self.fileUrl settings:recordSetting error:nil];
    recorder.delegate = self;    
}

-(void) setInputGain {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError* error;
    if(session.isInputGainSettable) {
        [session setInputGain:DEFAULT_GAIN error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        }
    } else {
        NSLog(@"input gain is not settable. Using default value : %f", session.inputGain);
    }
}

-(void) record {
    if(!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        [session setCategory:AVAudioSessionCategoryRecord error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        } else {
            [session setActive:YES error:nil];
            if(![recorder record]) {
                [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not start record", @"Error message") code:0 userInfo:nil]];
            } else {
                timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
            }
        }
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Recording is already acitve", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) pause {
    if(recorder.recording) {
        [recorder pause];
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Recording is not acitve", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) resume {
    if(![recorder record]) {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not resume", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) stop {
    [timer invalidate];
    timer = nil;
    [recorder stop];    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) {
        [self.delegate operationFailure:error];
    }
}

-(void)onTick:(NSTimer *)timer {
    [self.delegate timerUpdated:recorder.currentTime + self.previousFileLength];
}

-(NSURL*) recordFileUrl {
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"PeppermintMessage.m4a", nil];
    return [NSURL fileURLWithPathComponents:pathComponents];
}

-(NSURL*) backUpFileUrl {
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"PeppermintBackUpFile.m4a", nil];
    return [NSURL fileURLWithPathComponents:pathComponents];
}

-(void) removeFileIfExistsAtUrl:(NSURL*) url {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:url.path]) {
        [fileManager removeItemAtURL:url error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        }
    }
}

-(void) backUpRecording {
    defaults_set_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH, [NSString stringWithFormat:@"%f",recorder.currentTime + self.previousFileLength]);
    [self stop];
    [self mixAudiosWithTargetUrl:[self backUpFileUrl] Completion:^{
        [self removeFileIfExistsAtUrl:self.fileUrl];
    }];
}

-(void) resetRecording {
    [self.delegate timerUpdated:0];
    self.previousFileLength = 0;
    [self removeFileIfExistsAtUrl:[self backUpFileUrl]];
}

-(void) prepareRecordData {
    [self mixAudiosWithTargetUrl:self.fileUrl Completion:^{
        [self removeFileIfExistsAtUrl:[self backUpFileUrl]];
        NSData *data = [[NSData alloc] initWithContentsOfURL:self.fileUrl];
        [self removeFileIfExistsAtUrl:[self fileUrl]];
        [self.delegate recordDataIsPrepared:data];
    }];
}

/****************************************************************************************************
 * Grabbed & Modified the mixAudios function from : http://stackoverflow.com/a/15241353/5171866
 *****************************************************************************************************/
-(void)mixAudiosWithTargetUrl:(NSURL*)targetUrl Completion:(void(^)(void))completion
{
    NSError *error;
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio  preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime mergedFileEndPoint = kCMTimeZero;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileUrlArray = [NSArray arrayWithObjects:[self backUpFileUrl], self.fileUrl, nil];
    for(int i=0; i<fileUrlArray.count; i++)
    {
        NSURL *url = [fileUrlArray objectAtIndex:i];
        if([fileManager fileExistsAtPath:url.path]) {
            AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
            AVMutableCompositionTrack* audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
            NSArray *audioAssetArray = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
            if(audioAssetArray.count > 0) {
                AVAssetTrack *assetTrack = [audioAssetArray objectAtIndex:0];
                [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetTrack.asset.duration) ofTrack:assetTrack atTime:mergedFileEndPoint error:&error];
                if (error) {
                    [self.delegate operationFailure:error];
                } else {
                    mergedFileEndPoint = CMTimeAdd(mergedFileEndPoint, assetTrack.asset.duration);
                }
            }
        }
    }
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:
                                          AVAssetExportPresetAppleM4A];
    [self removeFileIfExistsAtUrl:targetUrl];
    
    _assetExport.outputFileType = AVFileTypeAppleM4A;
    _assetExport.outputURL = targetUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    [_assetExport exportAsynchronouslyWithCompletionHandler:completion];
}

@end
