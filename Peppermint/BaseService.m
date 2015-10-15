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
        self.baseUrl = BASE_URL;
    }
    return self;
}

@end
