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
    NSDate *now = [[NSDate new] localDateTime];
    NSTimeInterval timeInterval = floor(now.timeIntervalSinceReferenceDate / DAY) * DAY;
    NSDate *today = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    return today;
}

-(NSDate*) localDateTime {
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSTimeInterval timeIntervalWithTimeZone =  self.timeIntervalSinceReferenceDate + timeZone.secondsFromGMT;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:timeIntervalWithTimeZone];
}

-(BOOL) isToday {
    NSDate *today = [self today];
    return [[self localDateTime] compare:today] != NSOrderedAscending;
}

-(BOOL) isYesterday {
    NSDate *yesterday = [[self today] dateByAddingTimeInterval: -DAY];
    return [[self localDateTime] compare:yesterday] != NSOrderedAscending;
}

+(NSDate*) maxOfDate1:(NSDate*) date1 date2:(NSDate*) date2 {
    if(!date1 && !date2) {
        return nil;
    }
    NSDate *laterDate = date1 ? date1 : date2; // nil control
    if ([date1 compare:date2] == NSOrderedDescending) {
        laterDate = date1;
    } else if ([date1 compare:date2] == NSOrderedAscending) {
        laterDate = date2;
    }
    return laterDate;
}

-(NSString*) monthDayStringWithTodayYesterday {
    NSString *resultText;
    if([self isToday]) {
        resultText = LOC(@"Today", @"Today");
    } else if ([self isYesterday]) {
        resultText = LOC(@"Yesterday", @"Yesterday");
    } else {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"MMM dd"];
        resultText = [dateFormatter stringFromDate:self];
    }
    return resultText;
}

@end
