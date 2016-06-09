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
@property (assign, nonatomic) BOOL recipientSyncCompleted;
@property (assign, nonatomic) BOOL recipientIsFirstCycleCompleted;

@property (strong, nonatomic) NSDate<Optional> *senderSinceDate;
@property (strong, nonatomic) NSDate<Optional> *senderUntilDate;
@property (strong, nonatomic) NSString<Optional> *senderNextUrl;
@property (assign, nonatomic) BOOL senderSyncCompleted;
@property (assign, nonatomic) BOOL senderIsFirstCycleCompleted;

@end

@implementation SyncDateHolder
@end

@implementation ChatEntrySyncModel {
    AWSService *awsService;
    NSInteger activeServiceCallCount;
    BOOL isSyncCompleted;
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
        activeServiceCallCount = 0;
        self.chatEntryModel = [ChatEntryModel new];
        self.chatEntryModel.delegate = self;
        self.recentContactsModel = [RecentContactsModel new];
        self.recentContactsModel.delegate = self;
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
            _syncDateHolder.recipientSyncCompleted = NO;
            _syncDateHolder.recipientIsFirstCycleCompleted = NO;
            
            _syncDateHolder.senderSinceDate = nil;
            _syncDateHolder.senderUntilDate = nil;
            _syncDateHolder.senderNextUrl = nil;
            _syncDateHolder.senderSyncCompleted = NO;
            _syncDateHolder.senderIsFirstCycleCompleted = NO;
        }
    }
    return _syncDateHolder;
}

-(void) updateSyncDateHolderForRecipient:(BOOL)isForRecipient  withNextQueryUrl:(NSString*)nextQueryUrl maxSinceDate:(NSDate*) maxSinceDate {
    //This function updates the parameters but do not save syncDateHolder.
    if(isForRecipient) {
        self.syncDateHolder.recipientNextUrl = nextQueryUrl;
        self.syncDateHolder.recipientSinceDate = [NSDate maxOfDate1:self.syncDateHolder.recipientSinceDate date2:maxSinceDate];
        if(!self.syncDateHolder.recipientSinceDate) {
            self.syncDateHolder.recipientSinceDate = [NSDate dateWithTimeIntervalSinceNow:0];
        }
        self.syncDateHolder.recipientSyncCompleted = !nextQueryUrl;
        self.syncDateHolder.recipientIsFirstCycleCompleted |= self.syncDateHolder.recipientSyncCompleted;
    } else {
        self.syncDateHolder.senderNextUrl = nextQueryUrl;
        self.syncDateHolder.senderSinceDate = [NSDate maxOfDate1:self.syncDateHolder.senderSinceDate date2:maxSinceDate];
        if(!self.syncDateHolder.senderSinceDate) {
            self.syncDateHolder.senderSinceDate = [NSDate dateWithTimeIntervalSinceNow:0];
        }
        self.syncDateHolder.senderSyncCompleted = !nextQueryUrl;
        self.syncDateHolder.senderIsFirstCycleCompleted |= self.syncDateHolder.senderSyncCompleted;
    }
}

-(void) saveSyncDateHolder {
    defaults_set_object(DEFAULTS_SYNC_DATE_HOLDER, self.syncDateHolder.toJSONString);
}

#pragma mark - SyncStatus

-(BOOL) isReciviedMessagesAreInSyncOfFirstCycle {
    return self.syncDateHolder.recipientIsFirstCycleCompleted;
}

-(BOOL) issentMessagesAreInSyncOfFirstCycle {
    return self.syncDateHolder.senderIsFirstCycleCompleted;
}

-(BOOL) isAllMessagesAreInSyncOfFirstCycle {
    return self.isReciviedMessagesAreInSyncOfFirstCycle && self.issentMessagesAreInSyncOfFirstCycle;
}

#pragma mark - Server Query

-(BOOL) isSyncProcessActive {
    return (activeServiceCallCount > 0 || !self.syncDateHolder.recipientSyncCompleted || !self.syncDateHolder.senderSyncCompleted)
    && [PeppermintMessageSender sharedInstance].isUserStillLoggedIn;
}

-(void) makeSyncRequestForMessages {
    isSyncCompleted = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self queryServerForIncomingMessagesForRecepient:NO];
    [self queryServerForIncomingMessagesForRecepient:YES];
}

-(void) notifyDelegateToFinishBackgroundFetchInCase {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.delegate syncStepCompleted:[NSArray new] isLastStep:YES];
}

-(BOOL) userLoggedInAndReadyForQuery {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    return peppermintMessageSender.accountId.length > 0 && peppermintMessageSender.exchangedJwt.length > 0;
}

-(void) queryServerForIncomingMessagesForRecepient:(BOOL)isRecipient {
    if(!self.userLoggedInAndReadyForQuery) {
        NSLog(@"Could not query Server, please complete login process first.");
        [self notifyDelegateToFinishBackgroundFetchInCase];
    } else {
        activeServiceCallCount ++;
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        
        NSDate *sinceDate = isRecipient ? self.syncDateHolder.recipientSinceDate : self.syncDateHolder.senderSinceDate;
        NSDate *untilDate = isRecipient ? self.syncDateHolder.recipientUntilDate : self.syncDateHolder.senderUntilDate;
        NSString *nextQueryUrl = isRecipient ? self.syncDateHolder.recipientNextUrl : self.syncDateHolder.senderNextUrl;
        
        self.syncDateHolder.recipientSyncCompleted = isRecipient ? NO : self.syncDateHolder.recipientSyncCompleted;
        self.syncDateHolder.senderSyncCompleted = !isRecipient ? NO : self.syncDateHolder.senderSyncCompleted;
        
        [awsService getMessagesForAccountId:peppermintMessageSender.accountId
                                        jwt:peppermintMessageSender.exchangedJwt
                                    nextUrl:nextQueryUrl
                                      order:ORDER_REVERSE
                                  sinceDate:sinceDate
                                  untilDate:untilDate
                                  recipient:isRecipient];
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
    activeServiceCallCount = 0;
    //Perform any reset operation if needed
}

SUBSCRIBE(GetMessagesAreSuccessful) {
    BOOL isUserStillLoggedIn = [[PeppermintMessageSender sharedInstance] isUserStillLoggedIn];
    if(!isUserStillLoggedIn) {
        NSLog(@" User has logged out during an existing service call. Ignoring the response from server.");
    } else if(event.sender == awsService) {
        [self processEvent:event];
    }
}

#pragma mark - Process Event

-(void) processEvent:(GetMessagesAreSuccessful*) event {
    NSMutableSet *mergedPeppermintChatEntrySet = [NSMutableSet new];
    NSMutableSet *mergedPeppermintContactSet = [NSMutableSet new];
    CustomContactModel *customContactModel = [CustomContactModel new];
    NSDate *maxSinceDate = nil;
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
    
    //Mark Processed Step
    [self updateSyncDateHolderForRecipient:event.isForRecipient withNextQueryUrl:event.nextUrl maxSinceDate:maxSinceDate];
    
    //Queue next query
    [self queueNextQueryAfterIsRecipient:event.isForRecipient withNextQueryUrl:event.nextUrl];
    
    //Complete processing
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
        [self saveSyncDateHolder];
        
        isSyncCompleted = (!isSyncCompleted && ![self isSyncProcessActive]);
        if(isSyncCompleted) {
            NSLog(@"Sync cycle completed.");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
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
    NSLog(@"%lu recentPeppermintContactsSavedSucessfully in ChatEntrySyncModel", (unsigned long)recentContactsArray.count);
}

#pragma mark - Next Sync Step Operations

-(void) queueNextQueryAfterIsRecipient:(BOOL)isForRecipient withNextQueryUrl:(NSString*) nextQueryUrl {
    activeServiceCallCount --;
    BOOL isCompleted = !nextQueryUrl;
    if(!isCompleted) {
        [self queryServerForIncomingMessagesForRecepient:isForRecipient];
    } else {
        NSLog(@"Completed queries for %@", isForRecipient ? @"Recipient" : @"Sender");
    }
}

@end
