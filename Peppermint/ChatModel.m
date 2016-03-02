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

+(NSArray*) unreadMessagesFromArray:(NSArray*) peppermintChatEntryArray {    
    NSArray *filteredArray = [peppermintChatEntryArray filteredArrayUsingPredicate:PREDICATE_UNREAD_MESSAGES];
    return filteredArray;
}

@end
