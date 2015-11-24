//
//  DeviceModel.h
//  Peppermint
//
//  Created by Yan Saraev on 11/16/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface DeviceModel : BaseModel

+ (NSString *)deviceName;
+ (NSString *)systemVersion;
+ (NSString *)applicationVersion;
+ (NSString *)platform;

+ (NSString *)summary;
+ (NSDictionary*)summaryDictionary;

@end
