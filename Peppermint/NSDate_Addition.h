//
//  NSDate_Addition.h
//  Peppermint
//
//  Created by Okan Kurtulus on 21/03/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDate_Addition)
-(BOOL) isToday;
-(BOOL) isYesterday;
+(NSDate*) maxOfDate1:(NSDate*) date1 date2:(NSDate*) date2;

@end
