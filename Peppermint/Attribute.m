//
//  Attribute.m
//  Peppermint
//
//  Created by Okan Kurtulus on 01/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "Attribute.h"

@implementation Attribute {
    NSDate *cachedDate;
}

-(NSDate*) createdDate;{
    if( !cachedDate) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];
        NSDate *dateGMT = [dateFormatter dateFromString:self.created];
        cachedDate = dateGMT;
    }
    return cachedDate;
}

@end
