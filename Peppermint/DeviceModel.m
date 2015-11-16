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
  NSArray * bodyComponents = @[[DeviceModel platform], [DeviceModel deviceName], [DeviceModel systemVersion], [DeviceModel applicationVersion], @"\n"];
  return [bodyComponents componentsJoinedByString:@"\n"];
}

+ (NSString *)deviceName {
  struct utsname systemInfo;
  uname(&systemInfo);
  
  NSString * device = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
  return [NSString stringWithFormat:@"Device: %@", device];
}

+ (NSString *)systemVersion {
  NSString * systemVersion = [[UIDevice currentDevice] systemVersion];
  return [NSString stringWithFormat:@"System Version: %@", systemVersion];
}

+ (NSString *)applicationVersion {
  return [NSString stringWithFormat:@"Version: %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

+ (NSString *)platform {
  return @"Platform: iOS";
}

@end
