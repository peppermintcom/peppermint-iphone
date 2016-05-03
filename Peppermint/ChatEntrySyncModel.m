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

#define FAR_FUTURE_DATE     [NSDate dateWithTimeIntervalSinceNow: 5 * YEAR];
#define SOME_RECENT_DATE    [NSDate dateWithTimeIntervalSinceNow: -1 * HOUR];

@interface SyncDateHolder : JSONModel
@property (strong, nonatomic) NSDate<Optional> *recipientSinceDate;
@property (strong, nonatomic) NSDate<Optional> *recipientUntilDate;
@property (strong, nonatomic) NSDate<Optional> *senderSinceDate;
@property (strong, nonatomic) NSDate<Optional> *senderUntilDate;
@end

@implementation SyncDateHolder
@end

@implementation ChatEntrySyncModel {
    AWSService *awsService;
    __block int activeServerQueryCount;
    __block BOOL queryForIncoming;
    __block NSString *nextUrl;
    SyncDateHolder *syncDateHolder;
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

#pragma mark - SyncDateHolder

-(SyncDateHolder*) syncDateHolder {
    if(!syncDateHolder) {
        NSString *syncDateHolderJson = defaults_object(DEFAULTS_SYNC_DATE_HOLDER);
        NSError *error;
        syncDateHolder = [[SyncDateHolder alloc] initWithString:syncDateHolderJson error:&error];
        if(error) {
            syncDateHolder = [SyncDateHolder new];
            syncDateHolder.recipientSinceDate = nil;
            syncDateHolder.recipientUntilDate = FAR_FUTURE_DATE;
            syncDateHolder.senderSinceDate = nil;
            syncDateHolder.senderUntilDate = FAR_FUTURE_DATE;
        }
    }
    return syncDateHolder;
}

#pragma mark - SyncStatus

-(BOOL) isSyncWithAPIProcessedOneFullCycle {
    return !self.syncDateHolder.recipientUntilDate && !self.syncDateHolder.recipientUntilDate;
}

#pragma mark - Server Query

-(BOOL) isSyncProcessActive {
    return activeServerQueryCount > 0
    && [PeppermintMessageSender sharedInstance].isUserStillLoggedIn;
}

-(void) makeSyncRequestForMessages {
    queryForIncoming = NO;
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
        
        NSDate *sinceDate = queryForIncoming ? syncDateHolder.recipientSinceDate : syncDateHolder.senderSinceDate;
        NSDate *untilDate = queryForIncoming ? syncDateHolder.recipientUntilDate : syncDateHolder.senderUntilDate;
        [awsService getMessagesForAccountId:peppermintMessageSender.accountId
                                        jwt:peppermintMessageSender.exchangedJwt
                                    nextUrl:nextUrl
                                      order:ORDER_REVERSE
                                  sinceDate:sinceDate
                                  untilDate:untilDate
                                  recipient:queryForIncoming];
    }
}

SUBSCRIBE(NetworkFailure) {
    if(event.sender == awsService) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self resetSyncDate];
        if([ConnectionModel sharedInstance].isInternetReachable) {
            [self makeSyncRequestForMessages];
        } else {
            [self.delegate operationFailure:[event error]];
        }
    }
}

-(void) resetSyncDate {
    self.syncDateHolder.recipientUntilDate = FAR_FUTURE_DATE;
    self.syncDateHolder.senderUntilDate = FAR_FUTURE_DATE;
    defaults_set_object(DEFAULTS_SYNC_DATE_HOLDER, [self syncDateHolder].toJSONString);
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
            NSLog(@"gotNewQueryRequestWhileServiceCallWasActive, so calling again...");
            [self makeSyncRequestForMessages];
        } else if(shouldProcessData) {
            nextUrl = event.nextUrl;
            [self processEvent:event];
        }
    }
}

#pragma mark - Process Event

-(void) processEvent:(GetMessagesAreSuccessful*) event {
    NSMutableSet *mergedPeppermintChatEntrySet = [NSMutableSet new];
    NSMutableSet *mergedPeppermintContactSet = [NSMutableSet new];
    
    CustomContactModel *customContactModel = [CustomContactModel new];
    for (Data *messageData in event.dataOfMessagesArray) {
        //Peppermint Chat Entry
        messageData.attributes.message_id = messageData.id;
        PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry createFromAttribute:messageData.attributes isIncomingMessage:event.isForRecipient];
        [mergedPeppermintChatEntrySet addObject:peppermintChatEntry];
        
        //Peppermint Contact
        PeppermintContact *peppermintContact = [[ContactsModel sharedInstance] matchingPeppermintContactForEmail:peppermintChatEntry.contactEmail
                                                                                    nameSurname:peppermintChatEntry.contactNameSurname];
        peppermintContact.lastPeppermintContactDate = [NSDate maxOfDate1:peppermintChatEntry.dateCreated
                                                                   date2:peppermintContact.lastPeppermintContactDate];
        [mergedPeppermintContactSet addObject:peppermintContact];
        
        //Custom Contact
        [customContactModel save:peppermintContact];
        
        //Min Until Date
        if(event.isForRecipient) {
            self.syncDateHolder.recipientUntilDate = [peppermintChatEntry.dateCreated earlierDate:self.syncDateHolder.recipientUntilDate];
        } else {
            self.syncDateHolder.senderUntilDate = [peppermintChatEntry.dateCreated earlierDate:self.syncDateHolder.senderUntilDate];
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.recentContactsModel saveMultiple:mergedPeppermintContactSet.allObjects];
    [self.chatEntryModel savePeppermintChatEntryArray:[mergedPeppermintChatEntrySet allObjects]];
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
    [self.delegate syncStepCompleted:savedPeppermintChatEnryArray];
    [self updateLastSyncDatesInPeppermintMessageSender];
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

#pragma mark - Next Sync Step Operations

-(void) updateLastSyncDatesInPeppermintMessageSender {
    [self checkAndMarkFullSyncCycleCompletedIfNeeded];
    if(nextUrl) {
        [self queryServerForIncomingMessages];
    } else if (!queryForIncoming) {
        queryForIncoming = YES;
        [self queryServerForIncomingMessages];
    } else {
        NSLog(@"Sync cycle completed.");
    }
}

-(void) checkAndMarkFullSyncCycleCompletedIfNeeded {
    BOOL isFirstSyncCycleFinishedForRecipient = !nextUrl && queryForIncoming && self.syncDateHolder.recipientUntilDate;
    
    if(isFirstSyncCycleFinishedForRecipient) {
        self.syncDateHolder.recipientUntilDate = nil;
        self.syncDateHolder.recipientSinceDate = SOME_RECENT_DATE;
    }
    
    BOOL isFirstSyncCycleFinishedForSender = !nextUrl && !queryForIncoming && self.syncDateHolder.senderUntilDate;
    if(isFirstSyncCycleFinishedForSender) {
        self.syncDateHolder.senderUntilDate = nil;
        self.syncDateHolder.senderSinceDate = SOME_RECENT_DATE;
    }
    
    defaults_set_object(DEFAULTS_SYNC_DATE_HOLDER, [self syncDateHolder].toJSONString);
}

@end
