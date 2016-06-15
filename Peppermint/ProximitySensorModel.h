//
//  ProximitySensorModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 16/03/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface ProximitySensorModel : BaseModel

@property (assign, atomic, readonly) __block UIDeviceOrientation currentDeviceOrientation;
@property (assign, atomic, readonly) __block BOOL isDeviceOrientationCorrectOnEar;
@property (assign, atomic, readonly) __block BOOL isDeviceCloseToUser;
@property (assign, atomic) BOOL isRecordingActive;

+ (instancetype) sharedInstance;
-(void) startMonitoring;
-(void) stopMonitoring;

@end
