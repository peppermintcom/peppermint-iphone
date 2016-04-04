//
//  BaseRecordingGestureViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 05/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseRecordingGestureViewController.h"
#import "ProximitySensorModel.h"

#define WAIT_FOR_SHAKE_DURATION     2

@interface BaseRecordingGestureViewController ()

@end

@implementation BaseRecordingGestureViewController {
    NSTimer *recordingPausedTimer;
}

@dynamic _recordingView;

- (void)viewDidLoad {
    [super viewDidLoad];
    recordingPausedTimer = nil;
    REGISTER();
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startListeningProximitySensor];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopListeningProximitySensor];
}

#pragma mark - Proximity Sensor Monitor

-(void) startListeningProximitySensor {
    [[ProximitySensorModel sharedInstance] startMonitoring];
    [self.view becomeFirstResponder];
}

-(void) stopListeningProximitySensor {
    [[ProximitySensorModel sharedInstance] stopMonitoring];
    [self.view resignFirstResponder];
}

SUBSCRIBE(ProximitySensorValueIsUpdated) {
    BOOL isDeviceTakenToEar = event.isDeviceCloseToUser && event.isDeviceOrientationCorrectOnEar;
    BOOL isDeviceTakenOutOfEar = !event.isDeviceCloseToUser;
    BOOL isRecording = !self._recordingView.hidden;
    
    if (isDeviceTakenToEar && !isRecording) {
        [self performSelectorOnMainThread:@selector(recordingIsTriggeredWithGesture) withObject:nil waitUntilDone:NO];
    } else if (isDeviceTakenOutOfEar && isRecording) {
        [self pauseRecordingAndTriggerTimer];
    }
}

-(void) pauseRecordingAndTriggerTimer {
    [recordingPausedTimer invalidate];
    recordingPausedTimer = [NSTimer scheduledTimerWithTimeInterval:WAIT_FOR_SHAKE_DURATION
                                                            target:self
                                                          selector:@selector(completeRecordingPauseProcess)
                                                          userInfo:nil
                                                           repeats:NO];
    [self._recordingView finishRecordingWithGestureIsValid:YES needsPause:YES];
}

-(void) completeRecordingPauseProcess {
    weakself_create();
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf._recordingView finishRecordingWithGestureIsValid:YES needsPause:NO];
    });
}

SUBSCRIBE(ShakeGestureOccured) {
    [self performSelectorOnMainThread:@selector(cancelSending) withObject:nil waitUntilDone:NO];
}

-(void) recordingIsTriggeredWithGesture {
    NSLog(@"recordingIsTriggeredWithGesture.");
}

-(void) cancelSending {
    NSLog(@"cancelSendingIsTriggeredWithGesture.");
    if(recordingPausedTimer) {
        [recordingPausedTimer invalidate];
        recordingPausedTimer = nil;
        [self._recordingView finishRecordingWithGestureIsValid:NO needsPause:NO];
    }
    [self._recordingView cancelMessageSending];
}

@end
