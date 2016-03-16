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
        
        NSString *dateFormat = nil;
        if(self.created.length == DATE_TIME_FORMAT_WITH_MSECONDS.length) {
            dateFormat = DATE_TIME_FORMAT_WITH_MSECONDS;
        } else if (self.created.length == DATE_TIME_FORMAT_WITH_SECONDS.length) {
            dateFormat = DATE_TIME_FORMAT_WITH_SECONDS;
        } else if (self.created.length > DATE_TIME_FORMAT_WITH_SECONDS.length) {
            dateFormat = DATE_TIME_FORMAT_WITH_SECONDS;
            [self.created substringToIndex:dateFormat.length];
        } else {
            NSLog(@"%@ is not a parsable date information!",self.created);
        }
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:dateFormat];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:GMT];
        [dateFormatter setTimeZone:gmt];
        NSDate *dateGMT = [dateFormatter dateFromString:self.created];
        cachedDate = dateGMT;
    }
    return cachedDate;
}

@end
