//
//  DeviceMotionMager.h
//  Pods
//
//  Created by Srinivasan Baskaran on 10/14/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

typedef void (^DMAccelerometerHandler)(CMAcceleration acceleration);
typedef void (^DMGyroHandler)(CMRotationRate rotation);

@interface DeviceMotionMager : NSObject

- (void) initWithAccelerometerUpdatesWithHandler:(DMAccelerometerHandler)acceleration;

- (void) initWithGyroUpdatesWithHandler:(DMGyroHandler)rotation;

@end
