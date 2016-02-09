//
//  Attribute.m
//  Peppermint
//
//  Created by Okan Kurtulus on 01/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "Attribute.h"

@implementation Attribute

-(NSDate*) createdDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateUTC = [dateFormatter dateFromString:self.created];
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [dateUTC dateByAddingTimeInterval:timeZoneSeconds];
    
    return dateInLocalTimezone;
}

@end
