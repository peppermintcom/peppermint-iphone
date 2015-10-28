//
//  LoginModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginModel.h"

@implementation LoginModel

-(id) init {
    self = [super init];
    if(self) {
        self.peppermintMessageSender = [PeppermintMessageSender new];
    }
    return self;
}

-(void) performGoogleLogin {
    self.peppermintMessageSender.nameSurname = @"Google User";
    self.peppermintMessageSender.email = @"okankurtulus@yahoo.com";
    [self.peppermintMessageSender save];
    [self.delegate loginSucceed];
}

-(void) performFacebookLogin {
    self.peppermintMessageSender.nameSurname = @"Facebook User";
    self.peppermintMessageSender.email = @"okankurtulus@facebook.com";
    [self.peppermintMessageSender save];
    [self.delegate loginSucceed];
}

-(void) performEmailLogin {
    [self.peppermintMessageSender save];
    [self.delegate loginSucceed];
}

@end