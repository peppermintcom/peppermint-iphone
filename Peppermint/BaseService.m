//
//  BaseService.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseService.h"

@implementation BaseService

-(id)init {
    self = [super init];
    if(self) {
        self.baseUrl = @"";
    }
    return self;
}

-(void)failureDuringRequestCreationWithError:(NSError*) error {
    NSLog(@"Create Request error: %@", error);
    NetworkFailure *failure = [NetworkFailure new];
    failure.error = error;
    PUBLISH(failure);
}

-(void)failureWithOperation:(AFHTTPRequestOperation*) operation andError:(NSError*) error {
    NSLog(@"Network Error: %@", error);
    NetworkFailure *failure = [NetworkFailure new];
    failure.error = error;
    PUBLISH(failure);
}

-(void)failureDuringJSONCastWithError:(NSError*) error {
    NSLog(@"JSON cast error: %@", error);
    NetworkFailure *failure = [NetworkFailure new];
    failure.error = error;
    PUBLISH(failure);
}

@end
