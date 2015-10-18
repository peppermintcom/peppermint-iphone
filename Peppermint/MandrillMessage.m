//
//  MandrillMessage.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "MandrillMessage.h"

@implementation MandrillMessage

-(id)init {
    self = [super init];
    if(self) {
        self.to = (NSMutableArray<MandrillToObject>*)[NSMutableArray  new];
        self.headers = [NSMutableDictionary new];
        self.tags = [NSMutableArray new];
        self.attachments = (NSMutableArray<MandrillMailAttachment>*)[NSMutableArray new];
    }
    return self;
}

@end
