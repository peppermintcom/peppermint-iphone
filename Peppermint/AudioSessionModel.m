//
//  AudioSessionModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 01/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "AudioSessionModel.h"
#import "AppDelegate.h"
#import "ProximitySensorModel.h"

@implementation AudioSessionModel {
    __block BOOL currentSessionState;
    __block BOOL isActiveForRecording;
}

+ (instancetype) sharedInstance {
    return SHARED_INSTANCE( [[self alloc] initShared] );
}

-(id) init {
    NSAssert(false, @"This model instance is singleton so should not be inited - %@", self);
    return nil;
}

-(id) initShared {
    self = [super init];
    if(self) {
        currentSessionState = NO;
        isActiveForRecording = NO;
        [self registerInterruptionNotification];
        [self registerRouteChangeNotification];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL) updateSessionState:(BOOL) destinationSessionState isForRecording:(BOOL) isForRecording {
    if(destinationSessionState != currentSessionState) {
        NSError *error = nil;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        if(destinationSessionState) {
            isActiveForRecording = isForRecording;
            [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
            if(error) {
                [AppDelegate handleError:error];
            }
        }
        
        if(!error) {
            [session setActive:destinationSessionState
                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                         error:&error];
            if(error) {
                [AppDelegate handleError:error];
            } else {
                currentSessionState = destinationSessionState;
                NSLog(@"Updated session state with success. Current State is %@", destinationSessionState ? @"Active" : @"Deactive");
            }
        }
    } else {
        NSLog(@"Not processing request. Current sesssion state is already %@", currentSessionState ? @"Active" : @"DeActive");
    }
    BOOL operationSuccess = (destinationSessionState == currentSessionState);
    return operationSuccess;
}

#pragma mark - Interrupt Handling 

-(void) registerInterruptionNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
}

- (void)audioSessionInterrupted:(NSNotification*)notification {
#warning "Investigate behaviout"
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    NSLog(@"Got audio interruption: %@",
          (type == AVAudioSessionInterruptionTypeBegan) ? @"AVAudioSessionInterruptionTypeBegan" : @"AVAudioSessionInterruptionTypeEnded");
    if ( type == AVAudioSessionInterruptionTypeBegan ) {
        [self.activeAudioPlayer stop];
        [self.activeAudioRecorder stop];
        //[self updateSessionState:NO];
    } else if ( type == AVAudioSessionInterruptionTypeEnded) {
        //[self updateSessionState:YES];
    }
}

#pragma mark - Route Change Handling

-(void) registerRouteChangeNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionRouteChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

- (void)audioSessionRouteChanged:(NSNotification*) notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    NSError *error;
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"---AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"---AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            break;
        default:
            break;
    }
}

-(void) checkAndUpdateRoutingIfNeeded {
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    ProximitySensorModel *proximitySensorModel = [ProximitySensorModel sharedInstance];
    BOOL isOnEar = proximitySensorModel.isDeviceOrientationCorrectOnEar && proximitySensorModel.isDeviceCloseToUser;
    
    /*
    AVAudioSessionPortDescription *portDescription = audioSession.currentRoute.outputs.lastObject;
    NSString *portType = portDescription.portType;
    NSString *portExplanation = portDescription.portName;
    NSString *uid = portDescription.UID;
    
    NSLog(@"%@, %@, %@", portType, portExplanation, uid);
    BOOL isCurrentRouteToReceiver = [portType isEqualToString:AVAudioSessionPortBuiltInReceiver];
     // && isCurrentRouteToReceiver
    */
    
    if(!isActiveForRecording && !isOnEar) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    } else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    }
    if(error) {
        [AppDelegate handleError:error];
    }
}

#pragma mark - ProximitySensor

SUBSCRIBE(ProximitySensorValueIsUpdated) {
    [self checkAndUpdateRoutingIfNeeded];
}



@end
