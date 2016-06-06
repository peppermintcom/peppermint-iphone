//
//  QueueModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 06/06/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "QueueModel.h"

@implementation QueueModel {
    dispatch_queue_t transcriptionQueue;
}

+ (instancetype) sharedInstance {
    return SHARED_INSTANCE( [[self alloc] initShared] );
}

-(id) init {
    NSAssert(false, @"This model instance is singleton so should not be inited - %@", self);
    return nil;
}

-(id) initShared {
    self = [super init];
    if(self) {
        transcriptionQueue = dispatch_queue_create("com.example.name", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


-(dispatch_queue_t) transcriptionQueue {
    return transcriptionQueue;
}

@end
