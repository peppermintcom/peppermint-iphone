//
//  NSmutableSet_Addition.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/03/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "NSmutableSet_Addition.h"

@implementation NSMutableSet (NSmutableSet_Addition)

- (void)addOrUpdateObject:(id)object {
    if([self containsObject:object]) {
        [self removeObject:object];
    }
    [self addObject:object];
}

@end
