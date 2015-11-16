//
//  AccountResponse.m
//  Peppermint
//
//  Created by Okan Kurtulus on 14/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "AccountResponse.h"

#define KEY_USER        @"u"
#define KEY_PASSWORD    @"password"

@implementation AccountResponse

-(instancetype)initWithDictionary:(NSDictionary*)dict error:(NSError**)err {
    NSDictionary *userDictionary = (NSDictionary*) [dict valueForKey:KEY_USER];
    NSMutableDictionary *userMutableDictionary = [NSMutableDictionary dictionaryWithDictionary:userDictionary];
    [userMutableDictionary setValue:@"****" forKey:KEY_PASSWORD];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
    [dictionary setValue:userMutableDictionary forKey:KEY_USER];
    return [super initWithDictionary:dictionary error:err];
}

@end
