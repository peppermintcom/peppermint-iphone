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

//REMOTE SERVICE ENDPOINT
#define BASE_URL            @"http://mandrill...."
#define ENDPOINT_LOCATION   @"/crud/location"

@interface BaseService : NSObject
@property(strong, nonatomic) NSString *baseUrl;

@end
