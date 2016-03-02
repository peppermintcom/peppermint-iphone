//
//  Attribute.m
//  Peppermint
//
//  Created by Okan Kurtulus on 01/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "Attribute.h"
#import "PeppermintChatEntry.h"

@implementation Attribute {
    NSDate *cachedDate;
}

-(NSDate*) createdDate;{
    if( !cachedDate) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:DATE_TIME_FORMAT];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:GMT];
        [dateFormatter setTimeZone:gmt];
        NSDate *dateGMT = [dateFormatter dateFromString:self.created];
        cachedDate = dateGMT;
    }
    return cachedDate;
}

@end
