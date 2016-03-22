//
//  FastReplyModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 21/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "FastReplyModel.h"
#import "ContactsModel.h"
#import "ChatModel.h"
#import "RecordingModel.h"

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

-(BOOL) setFastReplyContactWithNameSurname:(NSString*)nameSurname email:(NSString*)email {
    NSAssert(nameSurname && email, @"Namesurname and email must be valid to add.Current data-> nameSurname:%@, email:%@", nameSurname, email);
    
    [[RecordingModel new] cleanCache];
    PeppermintContact *contact = [[ContactsModel sharedInstance] matchingPeppermintContactForEmail:email
                                                                                                 nameSurname:nameSurname];
    
    
    contact.hasReceivedMessageOverPeppermint = [[ChatModel receivedMessagesEmailSet] containsObject:email];
    [FastReplyModel sharedInstance].peppermintContact = contact;    
    ReplyContactIsAdded *replyContactIsAdded = [ReplyContactIsAdded new];
    replyContactIsAdded.sender = self;
    PUBLISH(replyContactIsAdded);
    
    return YES;
}

-(void) cleanFastReplyContact {
    [FastReplyModel sharedInstance].peppermintContact = nil;
}

-(BOOL) doesFastReplyContactsContains:(NSString*) filterText {
    filterText = [filterText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    BOOL nameSurnameMatches = NO;
    BOOL communicationChannelAddressMatches = NO;
    if(IS_IOS8_2_AND_UP) {
        nameSurnameMatches = [self.peppermintContact.nameSurname localizedCaseInsensitiveContainsString:filterText];
        communicationChannelAddressMatches = [self.peppermintContact.communicationChannelAddress localizedCaseInsensitiveContainsString:filterText];
    } else {
        nameSurnameMatches = [self.peppermintContact.nameSurname.lowercaseString containsString:filterText.lowercaseString];
        communicationChannelAddressMatches = [self.peppermintContact.communicationChannelAddress.lowercaseString containsString:filterText.lowercaseString];
    }
    
    return self.peppermintContact
    && (filterText.length == 0
        || nameSurnameMatches
        || communicationChannelAddressMatches
        );    
}

@end
