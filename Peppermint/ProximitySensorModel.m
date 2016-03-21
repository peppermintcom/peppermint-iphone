//
//  ProximitySensorModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 16/03/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ProximitySensorModel.h"
#import "DeviceMotionMager.h"

#define SENSITIVITY     0.75

@implementation ProximitySensorModel {
    DeviceMotionMager *_deviceMotionMager;
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

-(void) startMonitoring {
    [self startListeningDeviceMotionMager];
}

-(void) stopMonitoring {
    [self stopListeningDeviceMotionMager];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)sensorStateMonitor:(NSNotificationCenter *)notification {
    [self updateSensorState:[[UIDevice currentDevice] proximityState]];
}

-(void) updateSensorState:(BOOL)state {
    _isDeviceCloseToUser = state;
    ProximitySensorValueIsUpdated *proximitySensorValueIsUpdated = [ProximitySensorValueIsUpdated new];
    proximitySensorValueIsUpdated.isDeviceCloseToUser = self.isDeviceCloseToUser;
    proximitySensorValueIsUpdated.deviceOrientation = self.currentDeviceOrientation;
    proximitySensorValueIsUpdated.isDeviceOrientationCorrectOnEar = self.isDeviceOrientationCorrectOnEar;
    PUBLISH(proximitySensorValueIsUpdated);
}

#pragma mark - Device Motion Manager

-(void) stopListeningDeviceMotionMager {
    _deviceMotionMager = nil;
}

-(void) startListeningDeviceMotionMager {
    [[self deviceMotionMager] initWithAccelerometerUpdatesWithHandler:^(CMAcceleration acceleration) {
        if (acceleration.x >= SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationLandscapeLeft;
            _isDeviceOrientationCorrectOnEar = YES;
        } else if (acceleration.x <= -SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationLandscapeRight;
            _isDeviceOrientationCorrectOnEar = YES;
        } else if (acceleration.y <= -SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationPortrait;
            _isDeviceOrientationCorrectOnEar = YES;
        } else if (acceleration.y >= SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            _isDeviceOrientationCorrectOnEar = NO;
        } else if (acceleration.z >= SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationFaceDown;
            _isDeviceOrientationCorrectOnEar = NO;
        } else if (acceleration.z <= -SENSITIVITY) {
            _currentDeviceOrientation = UIDeviceOrientationFaceUp;
            _isDeviceOrientationCorrectOnEar = NO;
        } else {
            _currentDeviceOrientation = UIDeviceOrientationUnknown;
            _isDeviceOrientationCorrectOnEar = YES;
        }
        
        if(_isDeviceOrientationCorrectOnEar && ![UIDevice currentDevice].proximityMonitoringEnabled) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
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

-(DeviceMotionMager*) deviceMotionMager {
    if(!_deviceMotionMager) {
        _deviceMotionMager = [[DeviceMotionMager alloc] init];
    }
    return _deviceMotionMager;
}

@end
