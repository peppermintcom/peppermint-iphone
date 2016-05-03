//
//  MessageGetRequest.m
//  Peppermint
//
//  Created by Okan Kurtulus on 29/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "MessageGetRequest.h"

@implementation MessageGetRequest {
    NSDateFormatter *dateFormatter;
}

-(id) init {
    self = [super init];
    if(self) {
        self.since = nil;
        self.order = ORDER_REVERSE;
    }
    return self;
}

-(NSDateFormatter*) dateFormatter {
    if(!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:DATE_TIME_FORMAT];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:GMT];
        [dateFormatter setTimeZone:gmt];
    }
    return dateFormatter;
}

-(void) setSinceDate:(NSDate*) sinceDate {
    if(sinceDate) {
        self.since = [self.dateFormatter stringFromDate:sinceDate];
    } else {
        self.since = nil;
    }
}

-(void) setUntilDate:(NSDate*) untilDate {
    if(untilDate) {
        self.until = [self.dateFormatter stringFromDate:untilDate];
    } else {
        self.until = nil;
    }
}

@end
