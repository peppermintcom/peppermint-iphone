//
//  FastReplyModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 21/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "FastReplyModel.h"

@implementation FastReplyModel

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
        self.peppermintContact = nil;
    }
    return self;
}

+(BOOL) setFastReplyContactWithNameSurname:(NSString*)nameSurname email:(NSString*)email {
    PeppermintContact *contact = [PeppermintContact new];
    contact.nameSurname = nameSurname;
    contact.communicationChannel = CommunicationChannelEmail;
    contact.communicationChannelAddress = email;
    contact.avatarImage = [UIImage imageNamed:@"avatar_empty"];;
    [FastReplyModel sharedInstance].peppermintContact = contact;
    
    ReplyContactIsAdded *replyContactIsAdded = [ReplyContactIsAdded new];
    replyContactIsAdded.sender = self;
    PUBLISH(replyContactIsAdded);
    
    return YES;
}

+(void) cleanFastReplyContact {
    [FastReplyModel sharedInstance].peppermintContact = nil;
}

@end
