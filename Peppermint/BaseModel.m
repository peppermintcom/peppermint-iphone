//
//  BaseModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

-(id) init {
    self = [super init];
    if(self) {
#if !(TARGET_OS_WATCH)
        REGISTER();
#endif
        //NSLog(@"Created:%@", self.description);
    }
    return self;
}

-(void) dealloc {
    //NSLog(@"Released:%@)", self.description);
}

@end
