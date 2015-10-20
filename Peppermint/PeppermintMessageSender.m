//
//  PeppermintMessageSender.m
//  Peppermint
//
//  Created by Okan Kurtulus on 20/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "PeppermintMessageSender.h"

@implementation PeppermintMessageSender

-(id) init {
    self = [super init];
    if(self) {
        self.nameSurname = (NSString*) defaults_object(DEFAULTS_KEY_SENDER_NAMESURNAME);
        self.email = (NSString*) defaults_object(DEFAULTS_KEY_SENDER_EMAIL);
    }
    return self;
}

-(void) save {
    defaults_set_object(DEFAULTS_KEY_SENDER_NAMESURNAME, self.nameSurname);
    defaults_set_object(DEFAULTS_KEY_SENDER_EMAIL, self.email);
}

-(BOOL) isValid {
    return self.nameSurname.length > 0
    && self.email.length > 0;
}

@end
