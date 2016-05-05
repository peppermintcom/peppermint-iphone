//
//  ProximitySensorModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 16/03/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ProximitySensorModel.h"
#import "DeviceMotionMager.h"


#define SENSITIVITY                     0.60     //SENSITIVITY TRESHOLD FOR DEVICE ORIENTATION
#define DEVICE_MOVEMENT_TRESHOLD        0.80      //TRESHOLD TO DECIDE DEVICE IS RAISING
#define ON_EAR_GRAVITIY_LIMIT_X         -0.35    //GRAVITY IS -0.95 - FLAT VALUE IS 0
#define ON_EAR_GRAVITIY_LIMIT_Y         -0.20    //GRAVITY IS -0.95 - FLAT VALUE IS 0
#define ON_EAR_GRAVITIY_LIMIT_Z         -9.00    //GRAVITY IS -0.95 - FLAT VALUE IS 0
#define PROXIMITY_IDLE_TIME             2.0

@implementation ProximitySensorModel {
    DeviceMotionMager *_deviceMotionMager;
    __block CMAcceleration previousMeasurement;
    NSTimer *proximityCancellationTimer;
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
        _isDeviceOrientationCorrectOnEar = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateMonitor:)
                                                     name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    }
    return self;
}

#pragma mark - ProximityCancellationTimer

-(void) startProximityTimer {
    proximityCancellationTimer = [NSTimer scheduledTimerWithTimeInterval:PROXIMITY_IDLE_TIME
                                                                  target:self
                                                                selector:@selector(proximitySensorIsNotActivatedInTime)
                                                                userInfo:nil
                                                                 repeats:NO];
}

-(void) stopProximityTimer {
    [proximityCancellationTimer invalidate];
    proximityCancellationTimer = nil;
}

-(void) proximitySensorIsNotActivatedInTime {
    [self stopProximityTimer];
    [self stopProximitySensor];
}

#pragma mark - Monitoring

-(void) startMonitoring {
    previousMeasurement.x = previousMeasurement.y = previousMeasurement.z = 0;
    [self stopProximityTimer];
    [self startListeningDeviceMotionMager];
}

-(void) stopMonitoring {
    [self stopListeningDeviceMotionMager];
    [self stopProximityTimer];
    [self stopProximitySensor];
}

- (void)sensorStateMonitor:(NSNotificationCenter *)notification {
    weakself_create();
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateSensorState:[[UIDevice currentDevice] proximityState]];
    });
}

-(void) startProximitySensor {
    NSLog(@"Activate proximity sensor.");
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}

-(void) stopProximitySensor {
    _isDeviceCloseToUser = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

-(void) updateSensorState:(BOOL)state {
    BOOL isDeviceOrientationStillCorrect = self.isDeviceOrientationCorrectOnEar;
    if(!isDeviceOrientationStillCorrect && state) {
        NSLog(@"Cancelling proximity sensor, cos the device orientation is not correct anymore.");
        [self stopProximitySensor];
    } else {
        [self stopProximityTimer];
        _isDeviceCloseToUser = state;
        ProximitySensorValueIsUpdated *proximitySensorValueIsUpdated = [ProximitySensorValueIsUpdated new];
        proximitySensorValueIsUpdated.isDeviceCloseToUser = self.isDeviceCloseToUser;
        proximitySensorValueIsUpdated.deviceOrientation = self.currentDeviceOrientation;
        proximitySensorValueIsUpdated.isDeviceOrientationCorrectOnEar = self.isDeviceOrientationCorrectOnEar;
        PUBLISH(proximitySensorValueIsUpdated);
        
        BOOL shouldStopProximitySensorWithLatency = (state == NO);
        if (shouldStopProximitySensorWithLatency) {
            [self startProximityTimer];
        }
    }
}

#pragma mark - Device Motion Manager

-(void) stopListeningDeviceMotionMager {
    _deviceMotionMager = nil;
}

-(void) startListeningDeviceMotionMager {
    [[self deviceMotionMager] initWithAccelerometerUpdatesWithHandler:^(CMAcceleration acceleration) {
        
        CGFloat tresholdForOnEar = -CGFLOAT_MAX;
        if (acceleration.x >= SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationLandscapeLeft;
            tresholdForOnEar = ON_EAR_GRAVITIY_LIMIT_X;
        } else if (acceleration.x <= -SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationLandscapeRight;
            tresholdForOnEar = ON_EAR_GRAVITIY_LIMIT_X;
        } else if (acceleration.y <= -SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationPortrait;
            tresholdForOnEar = ON_EAR_GRAVITIY_LIMIT_Y;
        } else if (acceleration.y >= SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            tresholdForOnEar = ON_EAR_GRAVITIY_LIMIT_Y;
        } else if (acceleration.z >= SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationFaceDown;
            tresholdForOnEar = ON_EAR_GRAVITIY_LIMIT_Z;
        } else if (acceleration.z <= -SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationFaceUp;
            tresholdForOnEar = ON_EAR_GRAVITIY_LIMIT_Z;
        } else {
            _currentDeviceOrientation = UIDeviceOrientationUnknown;
        }
        
        _isDeviceOrientationCorrectOnEar = acceleration.y < tresholdForOnEar;
        BOOL isDeviceRaised = [self checkIfDeviceIsRaisedWithNewMeasurement:acceleration];
        
        if(_isDeviceOrientationCorrectOnEar
           && isDeviceRaised
           && ![UIDevice currentDevice].proximityMonitoringEnabled) {
            [self startProximitySensor];
            [self startProximityTimer];
        }
    }];
    
    /* //Currently rotation is not used.
    [[self deviceMotionMager] initWithGyroUpdatesWithHandler:^(CMRotationRate rotation) {
        //NSLog(@"ROTATION x: %.4f\ty: %.4f\tz: %.4f", rotation.x, rotation.y, rotation.z);
        NSString *rotationText = @"";
        if(rotation.x > SENSITIVITY || rotation.x < -SENSITIVITY) {
            rotationText = @"Rotation on X";
        } else if (rotation.y > SENSITIVITY || rotation.y < -SENSITIVITY) {
            rotationText = @"Rotation on Y";
        } else if (rotation.z > SENSITIVITY || rotation.z < -SENSITIVITY) {
            rotationText = @"Rotation on Z";
        } else {
            rotationText = @"Stable";
        }
    }];
    */
}

-(BOOL) checkIfDeviceIsRaisedWithNewMeasurement:(CMAcceleration)acceleration {
    BOOL isDeviceRaising = NO;
    if ((fabs(previousMeasurement.z) < 0.0001) && (fabs(previousMeasurement.y) < 0.0001) && (fabs(previousMeasurement.x) < 0.0001)) {
        previousMeasurement = acceleration;
    } else {
        CGFloat diffX = acceleration.x - previousMeasurement.x;
        CGFloat diffY = acceleration.y - previousMeasurement.y;
        CGFloat diffZ = acceleration.z - previousMeasurement.z;
        previousMeasurement = acceleration;
        CGFloat consolideAcc = fabs(diffX) + fabs(diffY) + fabs(diffZ);
        isDeviceRaising = consolideAcc > DEVICE_MOVEMENT_TRESHOLD;
    }
    return isDeviceRaising;
}

-(DeviceMotionMager*) deviceMotionMager {
    if(!_deviceMotionMager) {
        _deviceMotionMager = [[DeviceMotionMager alloc] init];
    }
    return _deviceMotionMager;
}

@end
