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

#define SESSION_DEACTIVATE_LATENCY     3

@implementation AudioSessionModel {
    NSMutableArray *activeAudioItemsArray;
    NSTimer *sessionDeactivateTimer;
    __block BOOL currentSessionState;
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
        activeAudioItemsArray = [NSMutableArray new];
        sessionDeactivateTimer = nil;
        currentSessionState = NO;
        [self registerInterruptionNotification];
        [self registerRouteChangeNotification];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) attachAVAudioProcessObject:(id)item {
    BOOL isClassValid = [item isKindOfClass:[AVAudioPlayer class]] || [item isKindOfClass:[AVAudioRecorder class]];
    NSAssert(isClassValid, @"attachAVAudioProcessObject: must be called with an instance of AVAudioPlayer or AVAudioRecorder");
    if(![activeAudioItemsArray containsObject:item]) {
        [activeAudioItemsArray addObject:item];
    }
}

-(BOOL) updateSessionState:(BOOL) destinationSessionState {
    [sessionDeactivateTimer invalidate];
    sessionDeactivateTimer = nil;
    
    BOOL result = YES;
    BOOL toSetActive = (destinationSessionState && !currentSessionState);
    BOOL toSetDeActive = (!destinationSessionState && currentSessionState);

    if(toSetActive && [self checkAndUpdateCategory]) {
         result = [self setSessionState:YES];
    } else if (toSetDeActive && [self canDeactivateAudioSession]) {
        sessionDeactivateTimer = [NSTimer scheduledTimerWithTimeInterval:SESSION_DEACTIVATE_LATENCY target:self selector:@selector(deactivateSessionState) userInfo:nil repeats:NO];
    } else {
        result = (currentSessionState == destinationSessionState);
    }
    return result;
}

-(BOOL) checkAndUpdateCategory {
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    BOOL result = [session.category isEqualToString:AVAudioSessionCategoryPlayAndRecord];
    if(!result) {
        result = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if(error) {
            [AppDelegate handleError:error];
        }
    }
    return result;
}

-(BOOL) canDeactivateAudioSession {
    BOOL canDeactivateSession = YES;
    for(NSObject *item in activeAudioItemsArray) {
        if(item && [item isKindOfClass:[AVAudioPlayer class]]) {
            AVAudioPlayer *player = (AVAudioPlayer*)item;
            canDeactivateSession &= !player.isPlaying;
        } else if (item && [item isKindOfClass:[AVAudioRecorder class]]) {
            AVAudioRecorder *recorder = (AVAudioRecorder*)item;
            canDeactivateSession &= !recorder.isRecording;
        }
        if(!canDeactivateSession) {
            break;
        }
    }
    return canDeactivateSession;
}

-(void) deactivateSessionState {
    if([self canDeactivateAudioSession]) {
        [activeAudioItemsArray removeAllObjects];
        [self setSessionState:NO];
    }
}

-(BOOL) setSessionState:(BOOL) destinationSessionState {
    BOOL result = NO;
    @try {
        NSError *error;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        result = [session setActive:destinationSessionState
                        withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                              error:&error];
        if(error) {
            [AppDelegate handleError:error];
        } else {
            currentSessionState = destinationSessionState;
        }
    }
    @catch ( NSException *e ) {
        NSLog(@"Got Exception:%@", e.description);
    }
    return result;
}

#pragma mark - Interrupt Handling

-(void) registerInterruptionNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
}

- (void)audioSessionInterrupted:(NSNotification*)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan ) {
        [self pauseActiveAudioItems];
    } else if ( type == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"AVAudioSessionInterruptionTypeEnded");
    }
    
    AudioSessionInterruptionOccured *audioSessionInterruptionOccured = [AudioSessionInterruptionOccured new];
    audioSessionInterruptionOccured.sender = self;
    audioSessionInterruptionOccured.hasInterruptionBegan = (type == AVAudioSessionInterruptionTypeBegan);
    PUBLISH(audioSessionInterruptionOccured);
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
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        case AVAudioSessionRouteChangeReasonCategoryChange:
            [self checkAndUpdateRoutingIfNeeded];
            [self resetActiveAudioItems];
            break;
        default:
            break;
    }
}

-(void) resetActiveAudioItems {
    for(NSObject *item in activeAudioItemsArray) {
        if (item && [item isKindOfClass:[AVAudioRecorder class]]) {
            AVAudioRecorder *recorder = (AVAudioRecorder*)item;
            if(recorder.isRecording) {
                [recorder stop];
                [recorder record];
            }
        } else if (item && [item isKindOfClass:[AVAudioPlayer class]]) {
            AVAudioPlayer *player = (AVAudioPlayer*)item;
            if(player.isPlaying) {
                [player stop];
                [player play];
            }
        }
    }
}

-(void) pauseActiveAudioItems {
    for(NSObject *item in activeAudioItemsArray) {
        if (item && [item isKindOfClass:[AVAudioRecorder class]]) {
            AVAudioRecorder *recorder = (AVAudioRecorder*)item;
            if(recorder.isRecording) {
                //We don't stop recorder. If we stop it will cause backup not to work!
                [recorder pause];
            }
        } else if (item && [item isKindOfClass:[AVAudioPlayer class]]) {
            AVAudioPlayer *player = (AVAudioPlayer*)item;
            if(player.isPlaying) {
                [player pause];
            }
        }
    }
}

-(void) checkAndUpdateRoutingIfNeeded {
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    ProximitySensorModel *proximitySensorModel = [ProximitySensorModel sharedInstance];
    BOOL isOnEar = proximitySensorModel.isDeviceOrientationCorrectOnEar && proximitySensorModel.isDeviceCloseToUser;
    AVAudioSessionPortDescription *portDescription = [AVAudioSession sharedInstance].currentRoute.outputs.lastObject;
    BOOL isCurrentRouteToReceiver = [portDescription.portType isEqualToString:AVAudioSessionPortBuiltInReceiver];
    
    if(!isOnEar && isCurrentRouteToReceiver) {
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

-(BOOL) isAudioSessionActive {
    return currentSessionState;
}

#pragma mark - App is in background

SUBSCRIBE(ApplicationWillResignActive) {
    [self pauseActiveAudioItems];
}

-(void) shutSessionDown {
    [sessionDeactivateTimer invalidate];
    sessionDeactivateTimer = nil;
    [self deactivateSessionState];
}

@end
