//
//  ChatEntrySyncModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 02/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntrySyncModel.h"
#import "AWSService.h"
#import "PeppermintMessageSender.h"
#import "ConnectionModel.h"
#import "ContactsModel.h"
#import "CustomContactModel.h"

@implementation ChatEntrySyncModel {
    AWSService *awsService;
    
    __block int activeServerQueryCount;
    __block BOOL queryForIncoming;
    
    NSMutableSet *mergedPeppermintChatEntrySet;
    NSMutableArray *mergedPeppermintContacts;
    
    __block NSString *nextUrl;
    NSDate *_lastMessageSyncDateForRecipient;
    NSDate *_lastMessageSyncDateForSender;
}

-(id) init {
    self = [super init];
    if(self) {
        awsService = [AWSService new];
        self.chatEntryModel = [ChatEntryModel new];
        self.chatEntryModel.delegate = self;
        self.recentContactsModel = [RecentContactsModel new];
        self.recentContactsModel.delegate = self;
        activeServerQueryCount = 0;
        queryForIncoming = NO;
    }
    return self;
}

#pragma mark - Server Query

-(BOOL) isSyncProcessActive {
    return activeServerQueryCount > 0;
}

-(void) makeSyncRequestForMessages {
    queryForIncoming = NO;
    mergedPeppermintChatEntrySet = [NSMutableSet new];
    mergedPeppermintContacts = [NSMutableArray new];
    nextUrl = nil;
    [self queryServerForIncomingMessages];
}

-(void) notifyDelegateToFinishBackgroundFetchInCase {
    [self.delegate syncStepCompleted:[NSArray new]];
}

-(void) queryServerForIncomingMessages {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    BOOL canQueryServer = peppermintMessageSender.accountId.length > 0 && peppermintMessageSender.exchangedJwt.length > 0;
    
    if(!canQueryServer) {
        NSLog(@"Could not query Server, please complete login process first.");
        [self notifyDelegateToFinishBackgroundFetchInCase];
    } else {
        ++activeServerQueryCount;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
        [self resetSyncDatesForCurrentLevel];
        if([ConnectionModel sharedInstance].isInternetReachable) {
            [self makeSyncRequestForMessages];
        } else {
            [self.delegate operationFailure:[event error]];
        }
    }
}

-(void) resetSyncDatesForCurrentLevel {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    BOOL isSynced = [peppermintMessageSender isSyncWithAPIProcessed];
    NSDate *recentDate = [NSDate dateWithTimeIntervalSinceNow:(-3 * HOUR)];
    NSDate *resetDate = [peppermintMessageSender defaultLastMessageSyncDate];
    
    _lastMessageSyncDateForRecipient = _lastMessageSyncDateForSender = nil;
    peppermintMessageSender.lastMessageSyncDate = isSynced ? recentDate : resetDate;
    peppermintMessageSender.lastMessageSyncDateForSentMessages = isSynced ? recentDate : resetDate;
    [peppermintMessageSender save];
}

SUBSCRIBE(GetMessagesAreSuccessful) {
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
    BOOL shouldManipulateSyncDate = ![peppermintMessageSender isSyncWithAPIProcessed];
    
    if(shouldManipulateSyncDate) {
        NSNumber *currentQuickSyncLevel = defaults_object(DEFAULTS_KEY_QUICK_SYNC_LEVEL);
        NSNumber *nextQuickSyncLevel = [NSNumber numberWithInt:(currentQuickSyncLevel.intValue + 1)];
        NSLog(@"QUICKSYNCLEVEL -> %@", nextQuickSyncLevel);
        defaults_set_object(DEFAULTS_KEY_QUICK_SYNC_LEVEL, nextQuickSyncLevel);
        [self resetSyncDatesForCurrentLevel];
        [self makeSyncRequestForMessages];
    } else {
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        peppermintMessageSender.lastMessageSyncDate = [self lastMessageSyncDateForRecipient];
        peppermintMessageSender.lastMessageSyncDateForSentMessages = [self lastMessageSyncDateForSender];
        _lastMessageSyncDateForRecipient = _lastMessageSyncDateForSender = nil;
        [peppermintMessageSender save];
    }
}

-(void) checkToUpdateLastSyncDate:(NSDate*)dateCreated isRecipient:(BOOL)isRecipient {
    if(isRecipient) {
        _lastMessageSyncDateForRecipient = [NSDate maxOfDate1:dateCreated date2:self.lastMessageSyncDateForRecipient];
    } else {
        _lastMessageSyncDateForSender = [NSDate maxOfDate1:dateCreated date2:self.lastMessageSyncDateForSender];
    }
}

#pragma mark - Last Message Date For Recent Contact

-(void) updateLastMessageDateForRecentContact:(PeppermintContact*)peppermintContact {
    if([mergedPeppermintContacts containsObject:peppermintContact]) {
        NSUInteger index = [mergedPeppermintContacts indexOfObject:peppermintContact];
        PeppermintContact *peppermintContactInList = [mergedPeppermintContacts objectAtIndex:index];
        peppermintContactInList.lastPeppermintContactDate = [NSDate maxOfDate1:peppermintContactInList.lastPeppermintContactDate
                                                                         date2:peppermintContact.lastPeppermintContactDate];
    } else {
        [mergedPeppermintContacts addObject:peppermintContact];
    }
}

#pragma mark - Process Event

-(void) processEvent:(GetMessagesAreSuccessful*) event {
    
    CustomContactModel *customContactModel = [CustomContactModel new];
    for (Data *messageData in event.dataOfMessagesArray) {
        messageData.attributes.message_id = messageData.id;
        PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry createFromAttribute:messageData.attributes isIncomingMessage:event.isForRecipient];
        
        [mergedPeppermintChatEntrySet addObject:peppermintChatEntry];
        
        [self checkToUpdateLastSyncDate:peppermintChatEntry.dateCreated
                            isRecipient:event.isForRecipient];
        
        PeppermintContact *peppermintContact = [[ContactsModel sharedInstance] matchingPeppermintContactForEmail:peppermintChatEntry.contactEmail
                                                                                    nameSurname:peppermintChatEntry.contactNameSurname];
        
        peppermintContact.lastPeppermintContactDate = [NSDate maxOfDate1:peppermintChatEntry.dateCreated
                                                                   date2:peppermintContact.lastPeppermintContactDate];
        [self updateLastMessageDateForRecentContact:peppermintContact];
        [customContactModel save:peppermintContact];
    }
    
    if(event.existsMoreMessages) {
        [self queryServerForIncomingMessages];
    } else if (!event.isForRecipient) {
        queryForIncoming = YES;
        [self queryServerForIncomingMessages];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.recentContactsModel saveMultiple:mergedPeppermintContacts];
        [self.chatEntryModel savePeppermintChatEntryArray:[mergedPeppermintChatEntrySet allObjects]];
    }
}

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
    [self.delegate operationFailure:error];
}

#pragma mark - ChatEntryModelDelegate

-(void) peppermintChatEntriesArrayIsUpdated {
    NSLog(@"peppermintChatEntriesArrayIsUpdated");
}

-(void) peppermintChatEntrySavedWithSuccess:(NSArray*) savedPeppermintChatEnryArray {
    [self updateLastSyncDatesInPeppermintMessageSender];
    [self.delegate syncStepCompleted:savedPeppermintChatEnryArray];
}

-(void) lastMessagesAreUpdated:(NSArray<PeppermintContactWithChatEntry*>*) peppermintContactWithChatEntryArray {
    NSLog(@"lastMessagesAreUpdated:");
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactsRefreshed {
    NSLog(@"recentPeppermintContactsRefreshed");
}

-(void) recentPeppermintContactsSavedSucessfully:(NSArray<PeppermintContact*>*) recentContactsArray {
    NSLog(@"%d recentPeppermintContactsSavedSucessfully in ChatEntrySyncModel", recentContactsArray.count);
}

@end
