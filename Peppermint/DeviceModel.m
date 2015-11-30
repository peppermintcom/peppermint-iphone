//
//  DeviceModel.m
//  Peppermint
//
//  Created by Yan Saraev on 11/16/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "DeviceModel.h"
#import <sys/utsname.h>

@implementation DeviceModel

+ (NSString *)summary {
  NSArray * bodyComponents = @[
                               @"",
                               @"",
                               @"",
                               @"",
                            [NSString stringWithFormat:@"Platform: %@",[DeviceModel platform]],
                            [NSString stringWithFormat:@"Device Hardware: %@", [DeviceModel deviceName]],
                            [NSString stringWithFormat:@"System Version: %@", [DeviceModel systemVersion]],
                            [NSString stringWithFormat:@"Version: %@", [DeviceModel applicationVersion]]
                               ];
  return [bodyComponents componentsJoinedByString:@"<br/>"];
}

+ (NSDictionary*)summaryDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self platform],                    @"Platform",
            [self deviceName],                  @"Hardware",
            [DeviceModel systemVersion],        @"System Version",
            [DeviceModel applicationVersion],   @"Version:",
            nil];
}

+ (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * device = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return device;
}

+ (NSString *)systemVersion {
    NSString * systemVersion = [[UIDevice currentDevice] systemVersion];
    return systemVersion;
}

+ (NSString *)applicationVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)platform {
  return @"iOS";
}

@end
