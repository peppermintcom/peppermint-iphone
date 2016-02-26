//
//  ChatModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatModel.h"
#import "Repository.h"
#import "ContactsModel.h"

#define PREDICATE_UNREAD_MESSAGES [NSPredicate predicateWithFormat:@"self.isSeen = %@",@NO]

@implementation ChatModel

-(id) init {
    self = [super init];
    if(self) {
        self.chatArray = [NSArray new];
    }
    return self;
}

#pragma mark - Refresh

-(void) refreshChatArray {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        
        Repository *repository = [Repository beginTransaction];
        NSArray *chatsArray = [repository getResultsFromEntity:[Chat class] predicateOrNil:nil ascSortStringOrNil:nil descSortStringOrNil:
                      [NSArray arrayWithObjects:@"lastMessageDate", nil]];
        
        NSMutableArray *chatPeppermintContactsArray = [NSMutableArray new];
        for(Chat *chat in chatsArray) {
            PeppermintContact *peppermintContact = [PeppermintContact new];
            peppermintContact.nameSurname = chat.nameSurname;
            peppermintContact.communicationChannel = chat.communicationChannel.integerValue;
            peppermintContact.communicationChannelAddress = chat.communicationChannelAddress;
            peppermintContact.avatarImage = [UIImage imageWithData:chat.avatarImageData];
            peppermintContact.lastMessageDate = chat.lastMessageDate;
            NSArray *unreadMessages = [repository getResultsFromEntity:[ChatEntry class]
                                                        predicateOrNil:
                                       [ChatModel unreadMessagesPredicateForEmail:peppermintContact.communicationChannelAddress]];
            peppermintContact.unreadMessageCount = unreadMessages.count;
            
            /*
            NSArray *lastChatEnries = [repository getResultsFromEntity:[ChatEntry class]
                                      predicateOrNil:[ChatModel lastChatEntryPredicateForEmail:peppermintContact.communicationChannelAddress]];
            
            if(lastChatEnries) {
                peppermintContact.lastMessageDate = ((ChatEntry*)lastChatEnries.firstObject).dateCreated;
            }
            */
            
            
            
            [chatPeppermintContactsArray addObject:peppermintContact];
        }
        weakSelf.chatArray = chatPeppermintContactsArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([weakSelf.delegate respondsToSelector:@selector(chatsArrayIsUpdated)]) {
                [weakSelf.delegate chatsArrayIsUpdated];
            }
        });
    });
}

#pragma mark - Chat Helper Functions

+(NSPredicate*) lastChatEntryPredicateForEmail:(NSString*) email {
    NSPredicate *lastChatEntryPredicate = [NSPredicate predicateWithFormat:@"self.contactEmail == %@ AND self.lastMessageDate==max(lastMessageDate)", email];
    return lastChatEntryPredicate;
}

+(NSPredicate*) unreadMessagesPredicateForEmail:(NSString*) email {
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"self.contactEmail == %@", email];
    return [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                        emailPredicate,
                                                        PREDICATE_UNREAD_MESSAGES,
                                                        nil]];
}

+(NSUInteger) unreadMessageCountOfAllChats {
    Repository *repository = [Repository beginTransaction];
    NSArray *unreadChatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:PREDICATE_UNREAD_MESSAGES];
    return  unreadChatEntries.count;
}

+(NSSet*) receivedMessagesEmailSet {
    Repository *repository = [Repository beginTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.isSentByMe == %@", @NO];
    NSArray *chatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
    
    NSMutableSet *mutableSet = [NSMutableSet new];
    for(ChatEntry *chatEntry in chatEntries) {
        [mutableSet addObject:chatEntry.contactEmail];
    }
    return mutableSet;
}

@end
