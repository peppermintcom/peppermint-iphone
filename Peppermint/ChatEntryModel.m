//
//  ChatEntryModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntryModel.h"
#import "Repository.h"
#import "PeppermintChatEntry.h"
#import "PeppermintMessageSender.h"
#import "AWSService.h"
#import "RecentContactsModel.h"
#import "ContactsModel.h"
#import "CustomContactModel.h"

@implementation ChatEntryModel {
    AWSService *awsService;
    __block int activeServerQueryCount;
    NSMutableSet *mergedPeppermintChatEntrySet;
    BOOL queryForIncoming;
}

-(id) init {
    self = [super init];
    if(self) {
        self.chatEntriesArray = [NSArray new];
        awsService = [AWSService new];
        activeServerQueryCount = 0;
        mergedPeppermintChatEntrySet = [NSMutableSet new];
        queryForIncoming = NO;
    }
    return self;
}

-(void) refreshPeppermintChatEntriesForContactEmail:(NSString*) contactEmail {
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        NSPredicate *chatPredicate = [NSPredicate predicateWithFormat:@"self.contactEmail == %@", contactEmail];
        Repository *repository = [Repository beginTransaction];
        NSArray *chatEntryArray = [repository getResultsFromEntity:[ChatEntry class]
                                                    predicateOrNil:chatPredicate
                                                ascSortStringOrNil:[NSArray arrayWithObjects:@"dateCreated", nil]
                                               descSortStringOrNil:nil];
        
        NSMutableArray *peppermintChatEntryArray = [NSMutableArray new];
        for(ChatEntry* chatEntry in chatEntryArray) {
            PeppermintChatEntry *peppermintChatEntry = [self peppermintChatEntryWith:chatEntry];
            [peppermintChatEntryArray addObject:peppermintChatEntry];
        }
        self.chatEntriesArray = peppermintChatEntryArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(peppermintChatEntriesArrayIsUpdated)]) {
                [self.delegate peppermintChatEntriesArrayIsUpdated];
            } else {
                NSLog(@"Delegate did not implement function peppermintChatEntriesArrayIsUpdated");
            }
        });
    });
}

-(PeppermintChatEntry*) peppermintChatEntryWith:(ChatEntry*)chatEntry {
    PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
    peppermintChatEntry.audio = chatEntry.audio;
    peppermintChatEntry.audioUrl = chatEntry.audioUrl;
    peppermintChatEntry.dateCreated = chatEntry.dateCreated;
    peppermintChatEntry.contactEmail = chatEntry.contactEmail;
    peppermintChatEntry.duration = chatEntry.duration.integerValue;
    peppermintChatEntry.isSeen = chatEntry.isSeen.boolValue;
    peppermintChatEntry.isSentByMe = chatEntry.isSentByMe.boolValue;
    peppermintChatEntry.messageId = chatEntry.messageId;
    return peppermintChatEntry;
}

#pragma mark - Save

-(void) savePeppermintChatEntry:(PeppermintChatEntry*)peppermintChatEntry {
    [self savePeppermintChatEntryArray:[NSArray arrayWithObject:peppermintChatEntry]];
}

-(void) savePeppermintChatEntryArray:(NSArray*)peppermintChatEntryArray {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        for(PeppermintChatEntry *peppermintChatEntry in peppermintChatEntryArray) {
            ChatEntry *chatEntry = nil;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.messageId == %@ OR self.audioUrl == %@", peppermintChatEntry.messageId, peppermintChatEntry.audioUrl];
            NSArray *existingChatEntriesArray = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
            
            if(!existingChatEntriesArray || existingChatEntriesArray.count == 0) {
                chatEntry = (ChatEntry*)[repository createEntity:[ChatEntry class]];
                peppermintChatEntry.performedOperation = PerformedOperationCreated;
            } else if(existingChatEntriesArray.count == 1) {
                chatEntry = existingChatEntriesArray.firstObject;
                [weakSelf checkChatEntry:chatEntry andMarkAsReadIfNeededWithPeppermintChatEntry:peppermintChatEntry];
                peppermintChatEntry.performedOperation = PerformedOperationUpdated;
            } else {
                NSString *errorText = [NSString stringWithFormat:
                                       @"Can not exists more than one message with same id %@", peppermintChatEntry.messageId];
                [exception(errorText) raise];
            }
            
            chatEntry.messageId = peppermintChatEntry.messageId;
            chatEntry.contactEmail = peppermintChatEntry.contactEmail;
            chatEntry.audio = peppermintChatEntry.audio;
            chatEntry.audioUrl = peppermintChatEntry.audioUrl;
            chatEntry.transcription = @"...Transcription should be added...";
            chatEntry.isSentByMe = [NSNumber numberWithBool:peppermintChatEntry.isSentByMe];
            chatEntry.dateCreated = peppermintChatEntry.dateCreated;
            chatEntry.isSeen = [NSNumber numberWithBool: peppermintChatEntry.isSeen
                                || (peppermintChatEntry.audio && peppermintChatEntry.isSentByMe)];
            chatEntry.duration = [NSNumber numberWithDouble:peppermintChatEntry.duration];
        }
        
        NSError *error = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                [weakSelf.delegate operationFailure:error];
            } else {
                mergedPeppermintChatEntrySet = [NSMutableSet new];
                [weakSelf.delegate peppermintChatEntrySavedWithSuccess:peppermintChatEntryArray];
            }
        });
    });
}

#pragma mark - Server Query

-(void) queryServerForIncomingMessages {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    BOOL canQueryServer = peppermintMessageSender.accountId.length > 0 && peppermintMessageSender.exchangedJwt.length > 0;
    
    if(!canQueryServer) {
        NSLog(@"Could not query Server, please complete login process first.");
    } else {
        ++activeServerQueryCount;
        if(queryForIncoming) {
            [awsService getMessagesForAccountId:peppermintMessageSender.accountId
                                            jwt:peppermintMessageSender.exchangedJwt
                                          since:peppermintMessageSender.lastMessageSyncDate
                                      recipient:YES];
        } else {
            [awsService getMessagesForAccountId:peppermintMessageSender.accountId
                                            jwt:peppermintMessageSender.exchangedJwt
                                          since:peppermintMessageSender.lastMessageSyncDateForSentMessages
                                      recipient:NO];
        }
    }
}

SUBSCRIBE(GetMessagesAreSuccessful) {
    if(event.sender == awsService) {
        BOOL gotNewQueryRequestWhileServiceCallWasActive = (--activeServerQueryCount > 0);
        activeServerQueryCount = 0;
        if(gotNewQueryRequestWhileServiceCallWasActive) {
            queryForIncoming = NO;
            [self queryServerForIncomingMessages];
        } else {
            [self processEvent:event];
        }
    }
}

-(void) processEvent:(GetMessagesAreSuccessful*) event {
    ContactsModel *contactsModel = [ContactsModel sharedInstance];
    NSMutableSet *peppermintContactsSet = [NSMutableSet new];
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    CustomContactModel *customContactModel = [CustomContactModel new];
    for (Data *messageData in event.dataOfMessagesArray) {
        messageData.attributes.message_id = messageData.id;
        PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry createFromAttribute:messageData.attributes
                                                                    forLoggedInAccountEmail:peppermintMessageSender.email];
        [mergedPeppermintChatEntrySet addObject:peppermintChatEntry];
        if([peppermintChatEntry.dateCreated laterDate:peppermintMessageSender.lastMessageSyncDate]) {
            if(queryForIncoming) {
                peppermintMessageSender.lastMessageSyncDate = peppermintChatEntry.dateCreated;
            } else {
               peppermintMessageSender.lastMessageSyncDateForSentMessages = peppermintChatEntry.dateCreated;
            }
        }
        
        PeppermintContact *peppermintContact = [contactsModel matchingPeppermintContactForEmail:peppermintChatEntry.contactEmail
                                                                                    nameSurname:peppermintChatEntry.contactNameSurname];
        
        if(!peppermintContact.lastMessageDate
           || [peppermintChatEntry.dateCreated laterDate:peppermintContact.lastMessageDate]) {
            peppermintContact.lastMessageDate = peppermintChatEntry.dateCreated;
        }
        [peppermintContactsSet addObject:peppermintContact];
        [customContactModel save:peppermintContact];
    }
    
    RecentContactsModel *recentContactsModel = [RecentContactsModel new];
    [recentContactsModel saveMultiple:[peppermintContactsSet allObjects]];
    
    [peppermintMessageSender save];
    
    NSLog(@"existsMoreMessages: %d , queryForIncoming:%d", event.existsMoreMessages, queryForIncoming);
    
    
    if(event.existsMoreMessages) {
        [self queryServerForIncomingMessages];
    } else if (!queryForIncoming) {
        queryForIncoming = YES;
        [self queryServerForIncomingMessages];
    } else {
        [self savePeppermintChatEntryArray:[mergedPeppermintChatEntrySet allObjects]];
    }
}

#pragma mark - Mark As Read

-(void) checkChatEntry:(ChatEntry*)chatEntry andMarkAsReadIfNeededWithPeppermintChatEntry:(PeppermintChatEntry*)peppermintChatEntry {
    if(!chatEntry.isSeen.boolValue && peppermintChatEntry.isSeen) {
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        [awsService markMessageAsReadWithJwt:peppermintMessageSender.exchangedJwt messageId:peppermintChatEntry.messageId];
    }
}

@end
