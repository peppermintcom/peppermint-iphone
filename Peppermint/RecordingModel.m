//
//  RecordingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingModel.h"
#import "RecordingModel_Addition.h"
//#import <AudioToolbox/AudioServices.h>

@implementation RecordingModel {
    NSTimer *timer;
    NSDate *pauseStart, *previousFireDate;
    __block NSTimeInterval previousMeasurement;
    NSTimeInterval _currentRecordingTime;
}

+(CGFloat) checkPreviousFileLength {
    NSString *length = (NSString*) defaults_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH);
    return length.floatValue;
}

+(void) setPreviousFileLength:(CGFloat) previousFileLength {
    defaults_set_object(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH, [NSString stringWithFormat:@"%f",previousFileLength]);
}

+(BOOL) checkRecordPermissions {
    BOOL __block result = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session requestRecordPermission:^(BOOL granted) {
            if(granted) {
                result = YES;
            } else {
                result = NO;
            }
        }];
    } else {
        result = YES;
    }
    return result;
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
    //NSLog(@"FileUrl is %@", self.fileUrl);
}

-(void) initRecorder {
    //@throw override_error;
    NSLog(@"initRecorder is called from BaseClass. Please override function in subclasses to add more functionality");
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
    return [[AudioSessionModel sharedInstance] updateSessionState:active];
}

-(void) record {
    previousMeasurement = _currentRecordingTime = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:PING_INTERVAL target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
}

-(void) pause {
    [self pauseTimer];
}

-(void) resume {
    [self resumeTimer];
}

-(void) stop {
    [timer invalidate];
    timer = nil;
}

#pragma mark - Recording Timer (Pause/Resume Timer)

-(NSTimeInterval) currentRecordingTime {
    return _currentRecordingTime;
}

-(void)updateMetering {
    @throw override_error
}

-(void)onTick:(NSTimer *)timer {
    _currentRecordingTime += PING_INTERVAL;
    [self updateMetering];
    CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
    
    NSTimeInterval diff = fabs(self.currentRecordingTime - previousMeasurement);
    BOOL isDiffValid = (diff < PING_INTERVAL * 100 && self.currentRecordingTime >= -0.00001);
    BOOL didGetReset = !isDiffValid && (self.currentRecordingTime > 0 && self.currentRecordingTime < PING_INTERVAL);
    
    if(isDiffValid || didGetReset) {
        previousMeasurement = self.currentRecordingTime;
        [self.delegate timerUpdated:self.currentRecordingTime + previousFileLength];
    }
}

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

#pragma mark - File Urls

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
    @throw override_error
}

-(void) resetRecording {
    [self.delegate timerUpdated:0];
    [RecordingModel setPreviousFileLength:0];    
    [self removeFileIfExistsAtUrl:[self backUpFileUrl]];
}

-(void) prepareRecordData {
    //Completion block for preparing Record
    void (^preparingProcess)(void) = ^(void) {
        //convertM4aToAAC is disabled. m4a is acceptable
        //if([TPAACAudioConverter AACConverterAvailable]) {
        //   [self convertM4aToAAC];
        //} else {
        //    NSLog(@"Can not convert to aac for this device!");
            NSData *data = [[NSData alloc] initWithContentsOfURL:self.fileUrl];
            [self removeFileIfExistsAtUrl:[self fileUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate recordDataIsPrepared:data withExtension:[self.fileUrl pathExtension]];
            });
        //}
    };
    
    //If there is a backUp - MixRecordings
    if([self fileExistsAtUrl:[self backUpFileUrl]]) {
        [self copyFileFrom:[self backUpFileUrl] targetUrl:self.fileUrl completion:^{
            preparingProcess();
        }];
    } else {
        preparingProcess();
    }
}


-(void) copyFileFrom:(NSURL*)sourceUrl targetUrl:(NSURL*)targetUrl completion:(void(^)(void))completion {
    NSError *error;
    
    if([self fileExistsAtUrl:sourceUrl]) {
        [self removeFileIfExistsAtUrl:targetUrl];
        [[NSFileManager defaultManager] copyItemAtPath:sourceUrl.path toPath:targetUrl.path error:&error];
        if(error) {
            [self.delegate operationFailure:error];
        } else {
            [self removeFileIfExistsAtUrl:sourceUrl];
            if(completion) {
                completion();
            }
        }
    } else if(completion) {
        completion();
    }
}

#pragma mark - Clean cached files

-(void) cleanCache {
    [self removeFileIfExistsAtUrl:[self recordFileUrl]];
    [self removeFileIfExistsAtUrl:[self backUpFileUrl]];
    [self removeFileIfExistsAtUrl:[self aacFileUrl]];
}

@end
