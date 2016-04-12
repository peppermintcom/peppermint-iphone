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

#define PREDICATE_UNREAD_MESSAGES [NSPredicate predicateWithFormat:@"self.isSeen = %@",@NO]

@implementation ChatEntryModel {
    AWSService *awsService;
    __block int activeServerQueryCount;
    NSMutableSet *mergedPeppermintChatEntrySet;
    NSMutableArray *mergedPeppermintContacts;
    __block BOOL queryForIncoming;
    __block NSString *nextUrl;
    RecentContactsModel *recentContactsModel;
    NSDate *_lastMessageSyncDateForRecipient;
    NSDate *_lastMessageSyncDateForSender;
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
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        NSPredicate *chatPredicate = [ChatEntryModel contactEmailPredicate:contactEmail];
        Repository *repository = [Repository beginTransaction];
        NSArray *chatEntryArray = [repository getResultsFromEntity:[ChatEntry class]
                                                    predicateOrNil:chatPredicate
                                                ascSortStringOrNil:[NSArray arrayWithObjects:@"dateCreated", nil]
                                               descSortStringOrNil:[NSArray arrayWithObjects:@"isSentByMe",  nil]];
        
        NSMutableArray *peppermintChatEntryArray = [NSMutableArray new];
        for(ChatEntry* chatEntry in chatEntryArray) {
            PeppermintChatEntry *peppermintChatEntry = [weakSelf peppermintChatEntryWith:chatEntry];
            if(peppermintChatEntry) {
                [peppermintChatEntryArray addObject:peppermintChatEntry];
            }
        }
        weakSelf.chatEntriesArray = peppermintChatEntryArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf && [weakSelf.delegate respondsToSelector:@selector(peppermintChatEntriesArrayIsUpdated)]) {
                [weakSelf.delegate peppermintChatEntriesArrayIsUpdated];
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
                                      AND (self.isSentByMe == %d))"
                                      , peppermintChatEntry.messageId
                                      , peppermintChatEntry.audioUrl
                                      , peppermintChatEntry.isSentByMe
                                      ];
            
            NSPredicate *emailPredicate = [ChatEntryModel contactEmailPredicate:peppermintChatEntry.contactEmail];
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                            predicate,
                                                                            emailPredicate,
                                                                            nil]];
            
            NSArray *existingChatEntriesArray = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
            
            if(!existingChatEntriesArray || existingChatEntriesArray.count == 0) {
                chatEntry = (ChatEntry*)[repository createEntity:[ChatEntry class]];
                peppermintChatEntry.performedOperation = PerformedOperationCreated;
            } else if(existingChatEntriesArray.count == 1) {
                chatEntry = existingChatEntriesArray.firstObject;
                [weakSelf checkChatEntry:chatEntry andMarkAsReadIfNeededWithPeppermintChatEntry:peppermintChatEntry];
                peppermintChatEntry.performedOperation = PerformedOperationUpdated;
            } else if(peppermintChatEntry.messageId != nil) {
                chatEntry = [existingChatEntriesArray objectAtIndex:0];
                int i=0;
                for(ChatEntry *chatEntry in existingChatEntriesArray) {
                    NSLog(@"%d.M:%@, A:%@, s:%@, c:%@", ++i, chatEntry.messageId, chatEntry.audioUrl, chatEntry.isSentByMe, chatEntry.contactEmail);
                }
                NSLog(@"More than 1 unique chatEntry record is active as seen above...");
            } else {
                exception(@"This case should not happen!");
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
                [weakSelf updateLastSyncDatesInPeppermintMessageSender];
                [weakSelf.delegate peppermintChatEntrySavedWithSuccess:peppermintChatEntryArray];
            }
        });
    });
}

#pragma mark - Server Query

-(BOOL) isSyncProcessActive {
    return activeServerQueryCount > 0;
}

-(void) makeSyncRequestForMessages {
    queryForIncoming = NO;
    mergedPeppermintChatEntrySet = [NSMutableSet new];
    mergedPeppermintContacts = [NSMutableArray new];
    recentContactsModel = [RecentContactsModel new];
    nextUrl = nil;
    [self queryServerForIncomingMessages];
}

-(void) notifyDelegateToFinishBackgroundFetchInCase {
    [self.delegate peppermintChatEntrySavedWithSuccess:[NSArray new]];
}

-(void) queryServerForIncomingMessages {    
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    BOOL canQueryServer = peppermintMessageSender.accountId.length > 0 && peppermintMessageSender.exchangedJwt.length > 0;
    
    if(!canQueryServer) {
        NSLog(@"Could not query Server, please complete login process first.");
        [self notifyDelegateToFinishBackgroundFetchInCase];
    } else {
        ++activeServerQueryCount;
        if(queryForIncoming) {
            [awsService getMessagesForAccountId:peppermintMessageSender.accountId
                                            jwt:peppermintMessageSender.exchangedJwt
                                        nextUrl:nextUrl
                                          since:[self lastMessageSyncDateForRecipient]
                                      recipient:YES];
        } else {
            [awsService getMessagesForAccountId:peppermintMessageSender.accountId
                                            jwt:peppermintMessageSender.exchangedJwt
                                        nextUrl:nextUrl
                                          since:[self lastMessageSyncDateForSender]
                                      recipient:NO];
        }
    }
}

SUBSCRIBE(NetworkFailure) {
    if(event.sender == awsService) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.delegate operationFailure:[event error]];
    }
}

SUBSCRIBE(GetMessagesAreSuccessful) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    BOOL isUserStillLoggedIn = [[PeppermintMessageSender sharedInstance] isUserStillLoggedIn];
    if(!isUserStillLoggedIn) {
        NSLog(@" User has logged out during an existing service call. Ignoring the response from server.");
    } else if(event.sender == awsService) {
        BOOL gotNewQueryRequestWhileServiceCallWasActive = (--activeServerQueryCount > 0);
        BOOL shouldProcessData = (activeServerQueryCount == 0);
        activeServerQueryCount = 0;
        if(gotNewQueryRequestWhileServiceCallWasActive) {
            [self makeSyncRequestForMessages];
        } else if(shouldProcessData) {
            nextUrl = event.nextUrl;
            [self processEvent:event];
        }
    }
}

#pragma mark - SyncDate functions

-(NSDate*) lastMessageSyncDateForRecipient {
    if(!_lastMessageSyncDateForRecipient) {
        _lastMessageSyncDateForRecipient = [PeppermintMessageSender sharedInstance].lastMessageSyncDate;
    }
    return _lastMessageSyncDateForRecipient;
}

-(NSDate*) lastMessageSyncDateForSender {
    if(!_lastMessageSyncDateForSender) {
        _lastMessageSyncDateForSender = [PeppermintMessageSender sharedInstance].lastMessageSyncDateForSentMessages;
    }
    return _lastMessageSyncDateForSender;
}

-(void) updateLastSyncDatesInPeppermintMessageSender {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    peppermintMessageSender.lastMessageSyncDate = [self lastMessageSyncDateForRecipient];
    peppermintMessageSender.lastMessageSyncDateForSentMessages = [self lastMessageSyncDateForSender];
    _lastMessageSyncDateForRecipient = _lastMessageSyncDateForSender = nil;
    [peppermintMessageSender save];
}

-(void) checkToUpdateLastSyncDate:(NSDate*)dateCreated isRecipient:(BOOL)isRecipient {
    BOOL isDateLaterForRecipient = dateCreated.timeIntervalSince1970 > [self lastMessageSyncDateForRecipient].timeIntervalSince1970;
    BOOL isDateLaterForSender = dateCreated.timeIntervalSince1970 > [self lastMessageSyncDateForSender].timeIntervalSince1970;
    
    if(isRecipient && isDateLaterForRecipient) {
        _lastMessageSyncDateForRecipient = dateCreated;
    } else if (!isRecipient && isDateLaterForSender) {
        _lastMessageSyncDateForSender = dateCreated;
    }
}

#pragma mark - Last Message Date For Recent Contact

-(void) updateLastMessageDateForRecentContact:(PeppermintContact*)peppermintContact {
    if([mergedPeppermintContacts containsObject:peppermintContact]) {
        NSUInteger index = [mergedPeppermintContacts indexOfObject:peppermintContact];
        PeppermintContact *peppermintContactInList = [mergedPeppermintContacts objectAtIndex:index];
        peppermintContactInList.lastMessageDate = [peppermintContactInList.lastMessageDate laterDate:peppermintContact.lastMessageDate];
    } else {
        [mergedPeppermintContacts addObject:peppermintContact];
    }
}

#pragma mark - Process Event

-(void) processEvent:(GetMessagesAreSuccessful*) event {
    ContactsModel *contactsModel = [ContactsModel sharedInstance];
    CustomContactModel *customContactModel = [CustomContactModel new];
    for (Data *messageData in event.dataOfMessagesArray) {
        messageData.attributes.message_id = messageData.id;
        PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry createFromAttribute:messageData.attributes isIncomingMessage:event.isForRecipient];
        
        [mergedPeppermintChatEntrySet addObject:peppermintChatEntry];
        
        [self checkToUpdateLastSyncDate:peppermintChatEntry.dateCreated
                            isRecipient:event.isForRecipient];
        
        PeppermintContact *peppermintContact = [contactsModel matchingPeppermintContactForEmail:peppermintChatEntry.contactEmail
                                                                                    nameSurname:peppermintChatEntry.contactNameSurname];
        
        peppermintContact.lastMessageDate = [peppermintChatEntry.dateCreated laterDate:peppermintContact.lastMessageDate];
        [self updateLastMessageDateForRecentContact:peppermintContact];
        [customContactModel save:peppermintContact];
    }
    
    if(event.existsMoreMessages) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self queryServerForIncomingMessages];
    } else if (!event.isForRecipient) {
        queryForIncoming = YES;
        [self queryServerForIncomingMessages];
    } else {
        [recentContactsModel saveMultiple:mergedPeppermintContacts];
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

-(void) markAllPreviousMessagesAsRead:(PeppermintChatEntry*)peppermintChatEntry {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        NSPredicate *emailPredicate = [ChatEntryModel contactEmailPredicate:peppermintChatEntry.contactEmail];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.dateCreated <= %@", peppermintChatEntry.dateCreated];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                        predicate,
                                                                        PREDICATE_UNREAD_MESSAGES,
                                                                        emailPredicate,
                                                                        nil]];
        
        NSDictionary *propertiesToUpdateDictionary = @{ @"isSeen" : @(YES) };
        NSInteger numberOfUpdatedEntities = [repository executeBatchUpdate:[ChatEntry class]
                                                            predicateOrNil:predicate
                                                       propertiesToConnect:propertiesToUpdateDictionary];
        NSError *error = [repository endTransaction];
        if(error) {
            [weakSelf.delegate operationFailure:error];
        } else {
            NSLog(@"%ld chatEntry Objects are marked as read.", numberOfUpdatedEntities);
        }
    });
}

#pragma mark - Chat Helper Functions

+(NSPredicate*) contactEmailPredicate:(NSString*) email {
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"self.contactEmail ==[cd] %@", email];
    return emailPredicate;
}

+(NSPredicate*) unreadMessagesPredicateForEmail:(NSString*) email {
    NSPredicate *emailPredicate = [ChatEntryModel contactEmailPredicate:email];
    return [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                               emailPredicate,
                                                               PREDICATE_UNREAD_MESSAGES,
                                                               nil]];
}

-(NSUInteger) unreadMessageCountOfAllChats {
    Repository *repository = [Repository beginTransaction];
    NSArray *unreadChatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:PREDICATE_UNREAD_MESSAGES];
    return  unreadChatEntries.count;
}

+(NSSet*) receivedMessagesEmailSet {
#warning "Add DB operations on background, even if they are quick as below. Probably to add block behaviour in function signature ;)"
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
