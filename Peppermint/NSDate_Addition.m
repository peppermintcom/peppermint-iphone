//
//  NSDate_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 21/03/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "NSDate_Addition.h"

@implementation NSDate (NSDate_Addition)

-(NSDate*) today {
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSTimeInterval timeIntervalWithTimeZone =  [NSDate new].timeIntervalSinceReferenceDate + timeZone.secondsFromGMT;
    NSTimeInterval timeInterval = floor(timeIntervalWithTimeZone / DAY) * DAY;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
}

-(BOOL) isToday {
    NSDate *today = [self today];
    return [self compare:today] != NSOrderedAscending;
}

-(BOOL) isYesterday {
    NSDate *yesterday = [[self today] dateByAddingTimeInterval: -DAY];
    return [self compare:yesterday] != NSOrderedAscending;
}

@end
