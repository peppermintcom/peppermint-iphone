//
//  AnalyticsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 16/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "AnalyticsModel.h"
#import <Crashlytics/Crashlytics.h>

@implementation AnalyticsModel

+(void) logError:(NSError*) error {
    [self logErrorToAnswers:error];
    [self logErrorToGoogleAnalytics:error];
}

+(void) logErrorToAnswers:(NSError*) error {
    NSMutableDictionary *logDictionary = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    [logDictionary setValue:[NSNumber numberWithInteger:error.code] forKey:@"Code"];
    [logDictionary setValue:error.domain forKey:@"Domain"];
    [logDictionary setValue:error.localizedDescription forKey:@"LocalizedDescription"];
    [logDictionary setValue:error.description forKey:@"Description"];
    [Answers logCustomEventWithName:@"NSError handled with alert" customAttributes:logDictionary];
}

+(void) logErrorToGoogleAnalytics:(NSError*) error {
    NSLog(@"%@", error);
}

@end
