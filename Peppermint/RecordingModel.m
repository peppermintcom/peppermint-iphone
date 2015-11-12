//
//  RecordingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingModel.h"
#import <AudioToolbox/AudioServices.h>

#define DEFAULT_GAIN    0.8 //Input Gain must be a value btw 0.0 - 1.0
#define PING_INTERVAL   0.2

@implementation RecordingModel {
    AVAudioRecorder *recorder;
    NSTimer *timer;
    TPAACAudioConverter *tPAACAudioConverter;
    NSDate *pauseStart, *previousFireDate;
}

+(CGFloat) checkPreviousFileLength {
    NSString *length = (NSString*) defaults_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH);
    return length.floatValue;
}

+(void) setPreviousFileLength:(CGFloat) previousFileLength {
    defaults_set_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH, [NSString stringWithFormat:@"%f",previousFileLength]);
}

-(id) init {
    self = [super init];
    if(self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            void (^permissionGranted)(RecordingModel*) = ^(RecordingModel *recordingModel) {
                [recordingModel performGrantedOperations];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [recordingModel.delegate accessRightsAreSupplied];
                });
            };
            
            __weak RecordingModel *weakSelf = self;
            AVAudioSession *session = [AVAudioSession sharedInstance];
            if([session respondsToSelector:@selector(requestRecordPermission:)]) {
                [session requestRecordPermission:^(BOOL granted) {
                    if(granted) {
                        permissionGranted(weakSelf);
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate microphoneAccessRightsAreNotSupplied];
                        });
                    }
                }];
            } else {
                permissionGranted(weakSelf);
            }
        });
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
    if(!recorder) {
        if([self setAudioSession:YES]) {
            NSError *error;
            NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                           [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                                           [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                           [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                           nil];
            recorder = [[AVAudioRecorder alloc] initWithURL:self.fileUrl settings:recordSetting error:&error];
            if(error) {
                [self.delegate operationFailure:error];
            }
            recorder.delegate = self;
        }
    } else {
        NSLog(@"Recorder was already active!!!");
    }
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
        //NSLog(@"input gain is not settable. Using default value : %f", session.inputGain);
    }
}

#pragma mark - Session Setting

-(BOOL) setAudioSession:(BOOL) active {
    BOOL result = NO;
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory :AVAudioSessionCategoryPlayAndRecord error:&error];
    if(error){
        [self.delegate operationFailure:error];
        result = NO;
    } else {
        [session setActive:active error:&error];
        if(error) {
            [self.delegate operationFailure:error];
            result = NO;
        } else {
            if(active) {
                [session setPreferredInputNumberOfChannels:1 error:&error];
                if(error) {
                    [self.delegate operationFailure:error];
                }
            }
            result = YES;
        }
    }
    return result;
}

-(void) record {
    if(!recorder.recording) {
        if([recorder record]) {
            timer = [NSTimer scheduledTimerWithTimeInterval:PING_INTERVAL target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
        } else {
            [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not start record", @"Error message") code:0 userInfo:nil]];
        }
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Recording is already acitve", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) pause {
    if(recorder.recording) {
        [self pauseTimer];
        [recorder pause];
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Recording is not acitve", @"Error message") code:0 userInfo:nil]];
    }
}

-(void) resume {
    if(![recorder record]) {
        [self.delegate operationFailure:[NSError errorWithDomain:LOC(@"Could not resume", @"Error message") code:0 userInfo:nil]];
    } else {
        [self resumeTimer];
    }
}

-(void) stop {
    [timer invalidate];
    timer = nil;
    [recorder stop];
}

-(void)onTick:(NSTimer *)timer {
    CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
    //NSLog(@"ticTac recorder:%f, previous:%f", recorder.currentTime, previousFileLength);
    [self.delegate timerUpdated:recorder.currentTime + previousFileLength];
}

-(NSURL*) recordFileUrl {
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"PeppermintMessage.m4a", nil];
    return [NSURL fileURLWithPathComponents:pathComponents];
}

-(NSURL*) backUpFileUrl {
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"PeppermintBackUpFile.m4a", nil];
    return [NSURL fileURLWithPathComponents:pathComponents];
}

-(NSURL*) aacFileUrl {
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"Peppermint.aac", nil];
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

-(BOOL) fileExistsAtUrl:(NSURL*) url {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:url.path];
}

-(void) backUpRecording {
    CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
    [RecordingModel setPreviousFileLength:recorder.currentTime + previousFileLength];
    [self stop];
    [self mixAudiosWithTargetUrl:[self backUpFileUrl] Completion:^{
        [self removeFileIfExistsAtUrl:self.fileUrl];
    }];
}

-(void) resetRecording {
    [self.delegate timerUpdated:0];
    [RecordingModel setPreviousFileLength:0];    
    [self removeFileIfExistsAtUrl:[self backUpFileUrl]];
}

-(void) prepareRecordData {
    //Completion block for preparing Record
    void (^preparingProcess)(void) = ^(void) {
        if(![TPAACAudioConverter AACConverterAvailable]) {
            NSLog(@"Can not convert to aac for this device!");
            NSData *data = [[NSData alloc] initWithContentsOfURL:self.fileUrl];
            [self removeFileIfExistsAtUrl:[self fileUrl]];
            [self setAudioSession:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate recordDataIsPrepared:data withExtension:[self.fileUrl pathExtension]];
            });
        } else {
            [self convertM4aToAAC];
        }
    };
    
    //If there is a backUp - MixRecordings
    if([self fileExistsAtUrl:[self backUpFileUrl]]) {
        [self mixAudiosWithTargetUrl:self.fileUrl Completion:^{
            [self removeFileIfExistsAtUrl:[self backUpFileUrl]];
            preparingProcess();
        }];
    } else {
        preparingProcess();
    }
}

/****************************************************************************************************
 * Grabbed & Modified the mixAudios function from : http://stackoverflow.com/a/15241353/5171866
 *****************************************************************************************************/
-(void)mixAudiosWithTargetUrl:(NSURL*)targetUrl Completion:(void(^)(void))completion
{
    
#warning "There is aproblem with mixing, solve it!"
    
    NSError *error;
    NSURL *sourceUrl = (targetUrl == self.fileUrl) ? [self backUpFileUrl] : self.fileUrl;
    
    if([self fileExistsAtUrl:sourceUrl]) {
        [self removeFileIfExistsAtUrl:targetUrl];
        [[NSFileManager defaultManager] copyItemAtPath:sourceUrl.path toPath:targetUrl.path error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        } else {
            completion();
        }
    } else {
        completion();
    }
    
    return;
    /*
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
    */
}

-(void) beep {
    //NSURL *directoryURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/SIMToolkitGeneralBeep.caf"];
    //NSURL *directoryURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/end_record.caf"];
    NSURL *directoryURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/jbl_begin.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)directoryURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark - Voice Record Conversion

-(void) convertM4aToAAC {
    // Register an Audio Session interruption listener, important for AAC conversion
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    tPAACAudioConverter = [[TPAACAudioConverter alloc] initWithDelegate:self
                                                                 source:[self fileUrl].path
                                                            destination:[self aacFileUrl].path];
    [self removeFileIfExistsAtUrl:[self aacFileUrl]];
    [tPAACAudioConverter start];
}

#pragma mark - TPAACAudioConverterDelegate

- (void)AACAudioConverterDidFinishConversion:(TPAACAudioConverter*)converter {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object: nil];
    NSData *data = [[NSData alloc] initWithContentsOfURL:[self aacFileUrl]];
    [self removeFileIfExistsAtUrl:[self fileUrl]];
    [self removeFileIfExistsAtUrl:[self aacFileUrl]];
    [self setAudioSession:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate recordDataIsPrepared:data withExtension:[[self aacFileUrl] pathExtension]];
    });
}

- (void)AACAudioConverter:(TPAACAudioConverter*)converter didFailWithError:(NSError*)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object: nil];
    
    
    [self.delegate operationFailure:error];
}

- (void)AACAudioConverter:(TPAACAudioConverter*)converter didMakeProgress:(CGFloat)progress {
    //NSLog(@"Progress:%f", progress);
}

#pragma mark - Audio session interruption

- (void)audioSessionInterrupted:(NSNotification*)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if ( type == AVAudioSessionInterruptionTypeEnded) {
        if ( [self setAudioSession:YES] && tPAACAudioConverter ) {
            [tPAACAudioConverter resume];
        }
    } else if ( type == AVAudioSessionInterruptionTypeBegan ) {
        if ( tPAACAudioConverter ) [tPAACAudioConverter interrupt];
    }
}

#pragma mark - Clean cached files

-(void) cleanCache {
    [self removeFileIfExistsAtUrl:[self recordFileUrl]];
    [self removeFileIfExistsAtUrl:[self backUpFileUrl]];
    [self removeFileIfExistsAtUrl:[self aacFileUrl]];
}

#pragma mark - Pause/Resume Timer

-(void) pauseTimer {
    pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    previousFireDate = [timer fireDate];
    [timer setFireDate:[NSDate distantFuture]];
}

-(void) resumeTimer {
    float pauseTime = -1*[pauseStart timeIntervalSinceNow];
    [timer setFireDate:[previousFireDate initWithTimeInterval:pauseTime sinceDate:previousFireDate]];
    pauseStart = previousFireDate = nil;
}

@end
