//
//  DeviceMotionMager.m
//  Pods
//
//  Created by Srinivasan Baskaran on 10/14/15.
//
//

#import "DeviceMotionMager.h"

@interface DeviceMotionMager()

@property (strong, nonatomic) CMMotionManager *motionManager;

@end

@implementation DeviceMotionMager


- (CMMotionManager *) motionManager {
    @synchronized(_motionManager) {
        if (_motionManager == nil) {
            _motionManager = [[CMMotionManager alloc] init];
            _motionManager.accelerometerUpdateInterval = .2;
            _motionManager.gyroUpdateInterval = .2;
        }
    }
    return _motionManager;
}

- (void) initWithAccelerometerUpdatesWithHandler:(DMAccelerometerHandler)acceleration {
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {

                                                 acceleration(accelerometerData.acceleration);
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];

}

- (void) initWithGyroUpdatesWithHandler:(DMGyroHandler)rotation {
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        rotation(gyroData.rotationRate);
                                    }];
}

@end
