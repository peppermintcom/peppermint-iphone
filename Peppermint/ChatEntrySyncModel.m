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

@interface SyncDateHolder : JSONModel

@property (strong, nonatomic) NSDate<Optional> *recipientSinceDate;
@property (strong, nonatomic) NSDate<Optional> *recipientUntilDate;
@property (strong, nonatomic) NSString<Optional> *recipientNextUrl;

@property (strong, nonatomic) NSDate<Optional> *senderSinceDate;
@property (strong, nonatomic) NSDate<Optional> *senderUntilDate;
@property (strong, nonatomic) NSString<Optional> *senderNextUrl;

@end

@implementation SyncDateHolder
@end

@implementation ChatEntrySyncModel {
    AWSService *awsService;
    __block int activeServerQueryCount;
    __block BOOL queryForIncoming;
    
    __block NSString *nextUrl;
    __block NSDate *maxSinceDate;
}

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
        awsService = [AWSService new];
        self.chatEntryModel = [ChatEntryModel new];
        self.chatEntryModel.delegate = self;
        self.recentContactsModel = [RecentContactsModel new];
        self.recentContactsModel.delegate = self;
        activeServerQueryCount = 0;
        queryForIncoming = NO;
        [self syncDateHolder];
    }
    return self;
}

SUBSCRIBE(UserLoggedOut) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _syncDateHolder = nil;
}

#pragma mark - SyncDateHolder

-(SyncDateHolder*) syncDateHolder {
    if(!_syncDateHolder) {
        NSString *syncDateHolderJson = defaults_object(DEFAULTS_SYNC_DATE_HOLDER);
        NSError *error;
        _syncDateHolder = [[SyncDateHolder alloc] initWithString:syncDateHolderJson error:&error];
        if(error) {
            _syncDateHolder = [SyncDateHolder new];
            _syncDateHolder.recipientSinceDate = nil;
            _syncDateHolder.recipientUntilDate = nil;
            _syncDateHolder.recipientNextUrl = nil;
            
            _syncDateHolder.senderSinceDate = nil;
            _syncDateHolder.senderUntilDate = nil;
            _syncDateHolder.senderNextUrl = nil;
        }
    }
    return _syncDateHolder;
}

#pragma mark - SyncStatus

-(BOOL) isReciviedMessagesAreInSyncOfFirstCycle {
    return (self.syncDateHolder.recipientSinceDate != nil);
}

-(BOOL) issentMessagesAreInSyncOfFirstCycle {
    return (self.syncDateHolder.senderSinceDate != nil);
}

-(BOOL) isAllMessagesAreInSyncOfFirstCycle {
    return self.isReciviedMessagesAreInSyncOfFirstCycle
    && self.issentMessagesAreInSyncOfFirstCycle;
}

#pragma mark - Server Query

-(BOOL) isSyncProcessActive {
    return activeServerQueryCount > 0
    && [PeppermintMessageSender sharedInstance].isUserStillLoggedIn;
}

-(void) makeSyncRequestForMessages {
    queryForIncoming = NO;
    nextUrl = nil;
    maxSinceDate = nil;
    [self queryServerForIncomingMessages];
}

-(void) notifyDelegateToFinishBackgroundFetchInCase {
    [self.delegate syncStepCompleted:[NSArray new] isLastStep:YES];
}

-(BOOL) userLoggedInAndReadyForQuery {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    return peppermintMessageSender.accountId.length > 0 && peppermintMessageSender.exchangedJwt.length > 0;
}

-(void) queryServerForIncomingMessages {
    if(!self.userLoggedInAndReadyForQuery) {
        NSLog(@"Could not query Server, please complete login process first.");
        [self notifyDelegateToFinishBackgroundFetchInCase];
    } else {
        ++activeServerQueryCount;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        
        NSDate *sinceDate = queryForIncoming ? self.syncDateHolder.recipientSinceDate : self.syncDateHolder.senderSinceDate;
        NSDate *untilDate = queryForIncoming ? self.syncDateHolder.recipientUntilDate : self.syncDateHolder.senderUntilDate;
        nextUrl = queryForIncoming ? self.syncDateHolder.recipientNextUrl : self.syncDateHolder.senderNextUrl;
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
        [self.delegate operationFailure:[event error]];
    }
}

-(void) resetSyncDate {
    //Perform any reset operation if needed
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
        //Max Since Date
        maxSinceDate = [NSDate maxOfDate1:peppermintChatEntry.dateCreated
                                    date2:maxSinceDate];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.recentContactsModel saveMultiple:mergedPeppermintContactSet.allObjects];
    [self.chatEntryModel savePeppermintChatEntryArray:[mergedPeppermintChatEntrySet allObjects]];
}

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self resetSyncDate];
    [self.delegate operationFailure:error];
}

#pragma mark - ChatEntryModelDelegate

-(void) peppermintChatEntriesArrayIsUpdated {
    NSLog(@"peppermintChatEntriesArrayIsUpdated");
}

-(void) peppermintChatEntrySavedWithSuccess:(NSArray*) savedPeppermintChatEnryArray {
    if(self.userLoggedInAndReadyForQuery) {
        BOOL isSyncCompleted = !nextUrl && queryForIncoming;
        [self updateLastSyncDatesInPeppermintMessageSender];
        [self.delegate syncStepCompleted:savedPeppermintChatEnryArray isLastStep:isSyncCompleted];
    }
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
        _syncDateHolder = nil;
    }
}

-(void) checkAndMarkFullSyncCycleCompletedIfNeeded {
    if(queryForIncoming) {
        self.syncDateHolder.recipientNextUrl = nextUrl;
        self.syncDateHolder.recipientSinceDate = nextUrl ? nil : maxSinceDate ? maxSinceDate : [NSDate dateWithTimeIntervalSinceNow:0];
    } else {
        self.syncDateHolder.senderNextUrl = nextUrl;
        self.syncDateHolder.senderSinceDate = nextUrl ? nil : maxSinceDate ? maxSinceDate : [NSDate dateWithTimeIntervalSinceNow:0];
    }
    defaults_set_object(DEFAULTS_SYNC_DATE_HOLDER, [self syncDateHolder].toJSONString);
}

@end
