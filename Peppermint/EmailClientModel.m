//
//  EmailClientModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "EmailClientModel.h"
#import "GmailEmailSessionModel.h"

@implementation EmailClientModel

-(id) init {
    self = [super init];
    if(self) {
        _emailSessionsArray = [NSMutableArray new];
    }
    return self;
}

-(void) stopExistingSessions {
    for(BaseEmailSessionModel *baseEmailSessionModel in self.emailSessionsArray) {
        [baseEmailSessionModel stopSession];
    }
    #warning Check for a possible memory leak if the session has errro on stop. Will it be released?
    [self.emailSessionsArray removeAllObjects];
}

-(void) startEmailClients {
    [self stopExistingSessions];
    
    //Start Logged in Gmail Account
    GmailEmailSessionModel *gmailEmailSessionModel = [GmailEmailSessionModel new];
    [self.emailSessionsArray addObject:gmailEmailSessionModel];
    [gmailEmailSessionModel initSession];
}

@end
