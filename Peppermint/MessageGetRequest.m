//
//  MessageGetRequest.m
//  Peppermint
//
//  Created by Okan Kurtulus on 29/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "MessageGetRequest.h"

@implementation MessageGetRequest

-(id) init {
    self = [super init];
    if(self) {
        self.since = nil;
    }
    return self;
}

-(void) setSinceDate:(NSDate*) sinceDate {
    if(sinceDate) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:DATE_TIME_FORMAT];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:GMT];
        [dateFormatter setTimeZone:gmt];
        self.since = [dateFormatter stringFromDate:sinceDate];
    }
}

@end
