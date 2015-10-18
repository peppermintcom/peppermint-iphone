//
//  BaseService.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Tolo.h"
#import "Events.h"

@interface BaseService : NSObject
@property(strong, nonatomic) NSString *baseUrl;

-(void)failureDuringRequestCreationWithError:(NSError*) error;
-(void)failureWithOperation:(AFHTTPRequestOperation*) operation andError:(NSError*) error;
-(void)failureDuringJSONCastWithError:(NSError*) error ;

@end
