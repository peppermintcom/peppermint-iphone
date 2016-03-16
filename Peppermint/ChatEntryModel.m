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
#import "ChatModel.h"

@implementation ChatEntryModel {
    AWSService *awsService;
    __block int activeServerQueryCount;
    NSMutableSet *mergedPeppermintChatEntrySet;
    NSMutableSet *mergedPeppermintContacts;
    __block BOOL queryForIncoming;
}

-(id) init {
    self = [super init];
    if(self) {
        self.chatEntriesArray = [NSArray new];
        awsService = [AWSService new];
        activeServerQueryCount = 0;
        queryForIncoming = NO;
    }
    return self;
}

-(void) refreshPeppermintChatEntriesForContactEmail:(NSString*) contactEmail {
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        NSPredicate *chatPredicate = [ChatModel contactEmailPredicate:contactEmail];
        Repository *repository = [Repository beginTransaction];
        NSArray *chatEntryArray = [repository getResultsFromEntity:[ChatEntry class]
                                                    predicateOrNil:chatPredicate
                                                ascSortStringOrNil:[NSArray arrayWithObjects:@"dateCreated", @"isSentByMe", nil]
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
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"((self.messageId == nil OR self.messageId == %@) \
                                      AND (self.audioUrl == nil OR self.audioUrl == %@) \
                                      AND (self.isSentByMe == %d) \
                                      AND (self.contactEmail == %@))"
                                      , peppermintChatEntry.messageId
                                      , peppermintChatEntry.audioUrl
                                      , peppermintChatEntry.isSentByMe
                                      , peppermintChatEntry.contactEmail
                                      ];
            NSArray *existingChatEntriesArray = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
            
            if(!existingChatEntriesArray || existingChatEntriesArray.count == 0) {
                chatEntry = (ChatEntry*)[repository createEntity:[ChatEntry class]];
                peppermintChatEntry.performedOperation = PerformedOperationCreated;
            } else if(existingChatEntriesArray.count == 1) {
                chatEntry = existingChatEntriesArray.firstObject;
                [weakSelf checkChatEntry:chatEntry andMarkAsReadIfNeededWithPeppermintChatEntry:peppermintChatEntry];
                peppermintChatEntry.performedOperation = PerformedOperationUpdated;
            } else if(peppermintChatEntry.messageId != nil) {
                
                for(ChatEntry *chatEntry in existingChatEntriesArray) {
                    NSLog(@"M:%@, A:%@, s:%@", chatEntry.messageId, chatEntry.audioUrl, chatEntry.isSentByMe);
                }
                
                NSString *errorText = [NSString stringWithFormat:
                                       @"Can not exists more than one message with same id %@", peppermintChatEntry.messageId];
                [exception(errorText) raise];
            }
            
            chatEntry.messageId = peppermintChatEntry.messageId;
            chatEntry.contactEmail = peppermintChatEntry.contactEmail;
            chatEntry.audio = peppermintChatEntry.audio ? peppermintChatEntry.audio : chatEntry.audio;
            chatEntry.audioUrl = peppermintChatEntry.audioUrl;
            chatEntry.transcription = @"...Transcription should be added...";
            chatEntry.isSentByMe = [NSNumber numberWithBool:peppermintChatEntry.isSentByMe];
            chatEntry.dateCreated = peppermintChatEntry.dateCreated;
            chatEntry.isSeen = [NSNumber numberWithBool:
                                chatEntry.isSeen.boolValue
                                || peppermintChatEntry.isSeen
                                || (peppermintChatEntry.audio && peppermintChatEntry.isSentByMe)];
            chatEntry.duration = [NSNumber numberWithDouble:peppermintChatEntry.duration];
        }
        
        NSError *error = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                [weakSelf.delegate operationFailure:error];
            } else {
                [weakSelf.delegate peppermintChatEntrySavedWithSuccess:peppermintChatEntryArray];
            }
        });
    });
}

#pragma mark - Server Query

-(void) makeSyncRequestForMessages {
    queryForIncoming = NO;
    mergedPeppermintChatEntrySet = [NSMutableSet new];
    mergedPeppermintContacts = [NSMutableSet new];
    [self queryServerForIncomingMessages];
}

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
    BOOL isUserStillLoggedIn = [PeppermintMessageSender sharedInstance].email.length > 0;
    if(!isUserStillLoggedIn) {
        NSLog(@" User has logged out during an existing service call. Ignoring the response from server.");
    } else if(event.sender == awsService) {
        BOOL gotNewQueryRequestWhileServiceCallWasActive = (--activeServerQueryCount > 0);
        BOOL shouldProcessData = (activeServerQueryCount == 0);
        activeServerQueryCount = 0;
        if(gotNewQueryRequestWhileServiceCallWasActive) {
            [self makeSyncRequestForMessages];
        } else if(shouldProcessData) {
            [self processEvent:event];
        }
    }
}

-(void) checkToUpdateLastSyncDate:(NSDate*)dateCreated forPeppermintMessageSender:(PeppermintMessageSender*)peppermintMessageSender isRecipient:(BOOL)isRecipient {
    if(isRecipient && [dateCreated laterDate:peppermintMessageSender.lastMessageSyncDate]) {
        peppermintMessageSender.lastMessageSyncDate = dateCreated;
    } else if (!isRecipient && [dateCreated laterDate:peppermintMessageSender.lastMessageSyncDateForSentMessages]) {
        peppermintMessageSender.lastMessageSyncDateForSentMessages = dateCreated;
    }
}

-(void) processEvent:(GetMessagesAreSuccessful*) event {
    ContactsModel *contactsModel = [ContactsModel sharedInstance];
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    CustomContactModel *customContactModel = [CustomContactModel new];
    for (Data *messageData in event.dataOfMessagesArray) {
        messageData.attributes.message_id = messageData.id;
        PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry createFromAttribute:messageData.attributes isIncomingMessage:event.isForRecipient];
        
        [mergedPeppermintChatEntrySet addObject:peppermintChatEntry];
        
        [self checkToUpdateLastSyncDate:peppermintChatEntry.dateCreated
             forPeppermintMessageSender:peppermintMessageSender
                            isRecipient:event.isForRecipient];
        
        PeppermintContact *peppermintContact = [contactsModel matchingPeppermintContactForEmail:peppermintChatEntry.contactEmail
                                                                                    nameSurname:peppermintChatEntry.contactNameSurname];
        
        if(!peppermintContact.lastMessageDate || [peppermintChatEntry.dateCreated laterDate:peppermintContact.lastMessageDate]) {
            peppermintContact.lastMessageDate = peppermintChatEntry.dateCreated;
        }
        
        [mergedPeppermintContacts addOrUpdateObject:peppermintContact];
        [customContactModel save:peppermintContact];
    }
    [peppermintMessageSender save];
    
    if(event.existsMoreMessages) {
        [self queryServerForIncomingMessages];
    } else if (!event.isForRecipient) {
        queryForIncoming = YES;
        [self queryServerForIncomingMessages];
    } else {
        RecentContactsModel *recentContactsModel = [RecentContactsModel new];
        [recentContactsModel saveMultiple:[mergedPeppermintContacts allObjects]];
        [self savePeppermintChatEntryArray:[mergedPeppermintChatEntrySet allObjects]];
    }
}

#pragma mark - Mark As Read

-(void) checkChatEntry:(ChatEntry*)chatEntry andMarkAsReadIfNeededWithPeppermintChatEntry:(PeppermintChatEntry*)peppermintChatEntry {
    if(!chatEntry.isSeen.boolValue && peppermintChatEntry.isSeen && peppermintChatEntry.messageId.length > 0) {
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        [awsService markMessageAsReadWithJwt:peppermintMessageSender.exchangedJwt messageId:peppermintChatEntry.messageId];
    }
}

#pragma mark - Update AudioUrl

-(void) updateChatEntryWithAudio:(NSData*)audio toAudioUrl:(NSString*)audioUrl {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.audio == %@ AND self.isSentByMe == %d", audio, YES];
        NSArray *matchingChatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
        if(matchingChatEntries.count == 1) {
            ChatEntry *chatEntry = matchingChatEntries.firstObject;
            chatEntry.audioUrl = audioUrl;
        } else {
            NSLog(@"Found chatEntries: %ld ", matchingChatEntries.count);
            if(matchingChatEntries.count == 0) {
                NSLog(@"Seems this is not a cached message");
            } else {
                for(ChatEntry *chatEntry in matchingChatEntries) {
                    NSLog(@"Chat Data: %@", chatEntry.audio);
                }
                NSLog(@"More than one chatEntry exists.");
            }
        }
        
        NSError *error = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                [weakSelf.delegate operationFailure:error];
            } else {
                NSLog(@"Operation success");
            }
        });
    });
}

@end
