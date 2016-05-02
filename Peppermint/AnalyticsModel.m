//
//  AnalyticsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 16/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "AnalyticsModel.h"
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#define EVENT_ATTR_MAX_LENGTH_FOR_CRASHLYTICS  100

@implementation AnalyticsModel

+(void) logError:(NSError*) error {
    [self logErrorToAnswers:error];
    [self logErrorToGoogleAnalytics:error];
    [self logErrorToFlurry:error];
}

+(NSMutableDictionary*) truncateEventValuesOf:(NSMutableDictionary*)logDictionary toLimit:(int) limit {
    for(NSString *key in logDictionary.allKeys) {
        NSString *value = nil;
        id object =[logDictionary valueForKey:key];
        
        [logDictionary removeObjectForKey:key];
        if([object isKindOfClass:[NSError class]]) {
            value = ((NSError*)object).localizedDescription;
        } else if ([object isKindOfClass:[NSString class]]) {
            value = (NSString*)object;
        }
        
        if(value && value.length > 0) {
            if(value.length > limit) {
                //Truncating values may cause loss of even data, but Crashlytics prevents length of 100. Check logs from other tracking platforms
                // Google Analytics or Flurry
                value = [value substringWithRange:NSMakeRange(0, limit)];
            }
            [logDictionary setObject:value forKey:key];
        }
    }
    return logDictionary;
}

+(void) logErrorToAnswers:(NSError*) error {
    NSMutableDictionary *logDictionary = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    [logDictionary setValue:[NSNumber numberWithInteger:error.code] forKey:@"Code"];
    [logDictionary setValue:error.domain forKey:@"Domain"];
    [logDictionary setValue:error.localizedDescription forKey:@"LocalizedDescription"];
    [logDictionary setValue:error.description forKey:@"Description"];
    logDictionary = [self truncateEventValuesOf:logDictionary toLimit:EVENT_ATTR_MAX_LENGTH_FOR_CRASHLYTICS];
    [Answers logCustomEventWithName:@"NSError handled with alert" customAttributes:logDictionary];
}

+(void) logErrorToGoogleAnalytics:(NSError*) error {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    NSString *action = [NSString stringWithFormat:@"%ld| %@ (%@)",
                        (long)error.code,
                        error.localizedDescription,
                        error.description];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:error.domain
                                                          action:action
                                                           label:error.userInfo.description
                                                           value:@1] build]];
}

+(void) logErrorToFlurry:(NSError*) error {
    [Flurry logError:error.localizedDescription message:@"NSError Occured" error:error];
    
}

@end
