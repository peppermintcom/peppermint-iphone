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
    
    NSDictionary *deviceDictionary = [self deviceNameDictionary];
    if([deviceDictionary.allKeys containsObject:device]) {
        device = [deviceDictionary valueForKey:device];
    }
    
    return device;
}

+ (NSString *)systemVersion {
    NSString * systemVersion = [[UIDevice currentDevice] systemVersion];
    return systemVersion;
}

+ (NSString *)applicationVersion {
    return [NSString stringWithFormat:@"%@ (%@)"
     ,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
     ,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
     ];
}

+ (NSString *)platform {
  return @"iOS";
}

+(NSDictionary*) deviceNameDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"32-bit Simulator",												@"i386"      	,
            @"64-bit Simulator",												@"x86_64"    	,
            @"iPod Touch",														@"iPod1,1"   	,
            @"iPod Touch Second Generation",									@"iPod2,1"   	,
            @"iPod Touch Third Generation",										@"iPod3,1"   	,
            @"iPod Touch Fourth Generation",									@"iPod4,1"   	,
            @"iPod Touch 6th Generation",										@"iPod7,1"   	,
            @"iPhone",															@"iPhone1,1" 	,
            @"iPhone 3G",														@"iPhone1,2" 	,
            @"iPhone 3GS",														@"iPhone2,1" 	,
            @"iPad",															@"iPad1,1"   	,
            @"iPad 2",															@"iPad2,1"   	,
            @"3rd Generation iPad",												@"iPad3,1"   	,
            @"iPhone 4 (GSM)",													@"iPhone3,1" 	,
            @"iPhone 4 (CDMA/Verizon/Sprint)",									@"iPhone3,3" 	,
            @"iPhone 4S",														@"iPhone4,1" 	,
            @"iPhone 5 (model A1428, AT&T/Canada)",								@"iPhone5,1" 	,
            @"iPhone 5 (model A1429, everything else)",							@"iPhone5,2" 	,
            @"4th Generation iPad",												@"iPad3,4" 		,
            @"iPad Mini",														@"iPad2,5" 		,
            @"iPhone 5c (model A1456, A1532 | GSM)",							@"iPhone5,3" 	,
            @"iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)",	@"iPhone5,4" 	,
            @"iPhone 5s (model A1433, A1533 | GSM)",							@"iPhone6,1" 	,
            @"iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)",	@"iPhone6,2" 	,
            @"5th Generation iPad (iPad Air) - Wifi",							@"iPad4,1" 		,
            @"5th Generation iPad (iPad Air) - Cellular",						@"iPad4,2" 		,
            @"2nd Generation iPad Mini - Wifi",									@"iPad4,4" 		,
            @"2nd Generation iPad Mini - Cellular",								@"iPad4,5" 		,
            @"3rd Generation iPad Mini - Wifi (model A1599)",					@"iPad4,7" 		,
            @"iPhone 6 Plus",													@"iPhone7,1" 	,
            @"iPhone 6",														@"iPhone7,2" 	,
            @"iPhone 6S",														@"iPhone8,1" 	,
            @"iPhone 6S Plus",													@"iPhone8,2" 	,
            nil];
}

@end
