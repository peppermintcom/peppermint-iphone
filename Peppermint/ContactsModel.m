//
//  ContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsModel.h"

@implementation ContactsModel

-(id) init {
    self = [super init];
    if(self) {
        self.contactList = [NSMutableArray new];
    }
    return self;
}

@end
