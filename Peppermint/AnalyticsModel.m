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

@implementation AnalyticsModel

+(void) logError:(NSError*) error {
    [self logErrorToAnswers:error];
    [self logErrorToGoogleAnalytics:error];
    [self logErrorToFlurry:error];
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
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    NSString *action = [NSString stringWithFormat:@"%ld.%@ - %@ (%@)", (long)error.code, error.domain, error.localizedDescription, error.description];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"NSError Occured"
                                                          action:action
                                                           label:error.userInfo.description
                                                           value:@1] build]];
}

+(void) logErrorToFlurry:(NSError*) error {
    [Flurry logError:@"NSError Occured" message:error.localizedDescription error:error];
    
}

@end
