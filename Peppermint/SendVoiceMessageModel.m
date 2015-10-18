//
//  SendVoiceMessageModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageModel.h"

@implementation SendVoiceMessageModel {
    RecentContactsModel *recentContactsModel;
}

-(id) init {
    self = [super init];
    if(self) {
        recentContactsModel = [RecentContactsModel new];
        recentContactsModel.delegate = self;
    }
    return self;
}

-(void) sendVoiceMessageWithData:(NSData*) data {
    [recentContactsModel save:self.selectedPeppermintContact];
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactSavedSucessfully:(PeppermintContact*) recentContact {
    //Contact is saved...
}

-(void) operationFailure:(NSError*) error {
    [self.delegate operationFailure:error];
}

@end
