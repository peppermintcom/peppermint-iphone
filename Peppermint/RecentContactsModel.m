//
//  RecentContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 10/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecentContactsModel.h"
#import "ContactsModel.h"
#import "ChatEntryModel.h"

@import WatchConnectivity;

#define DBQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

@implementation RecentContactsModel {
    __block NSSet *receivedMessagesEmailSet;
    __block int activeServiceCallCount;
    __block NSMutableArray *contactList;
    NSMutableArray *peppermintMessageRecentContactsArray;
    NSMutableArray *mailClientMessageRecentContactsArray;
}

-(id) init {
    self = [super init];
    if(self) {
        contactList = [NSMutableArray new];
        receivedMessagesEmailSet = nil;
        activeServiceCallCount = 0;
        peppermintMessageRecentContactsArray = nil;
        mailClientMessageRecentContactsArray = nil;
    }
    return self;
}

-(void) save:(PeppermintContact*) peppermintContact forLastPeppermintContactDate:(NSDate*)lastPeppermintContactDate lastMailClientContactDate:(NSDate*) lastMailClientContactDate {
    peppermintContact.lastPeppermintContactDate = lastPeppermintContactDate;
    peppermintContact.lastMailClientContactDate = lastMailClientContactDate;
    [self saveMultiple:[NSArray arrayWithObject:peppermintContact]];
}

-(void) saveMultiple:(NSArray<PeppermintContact*>*) peppermintContactArray {
    weakself_create();
    dispatch_async(DBQueue, ^() {
        Repository *repository = [Repository beginTransaction];
        
        for(PeppermintContact *peppermintContact in peppermintContactArray) {
            if(!peppermintContact.isRestrictedForRecentContact) {
                [peppermintContact addToCoreSpotlightSearch];
                NSPredicate *predicate = [weakSelf recentContactPredicate:peppermintContact];
                NSArray *matchedRecentContacts = [repository getResultsFromEntity:[RecentContact class] predicateOrNil:predicate];
                
                RecentContact *recentContact = nil;
                if (matchedRecentContacts.count == 0) {
                    recentContact = (RecentContact*)[repository createEntity:[RecentContact class]];
                } else if (matchedRecentContacts.count == 1) {
                    recentContact = [matchedRecentContacts firstObject];
                } else {
                    [weakSelf promtMultipleRecordsWithSameValueErrorForPeppermintContact:peppermintContact];
                }
                recentContact.peppermintContactDate = [NSDate maxOfDate1:peppermintContact.lastPeppermintContactDate
                                                                   date2:recentContact.peppermintContactDate];
                
                recentContact.mailClientContactDate = [NSDate maxOfDate1:peppermintContact.lastMailClientContactDate
                                                                   date2:recentContact.mailClientContactDate];
                
                recentContact.nameSurname = peppermintContact.nameSurname;
                recentContact.communicationChannelAddress = peppermintContact.communicationChannelAddress;
                recentContact.communicationChannel = [NSNumber numberWithInt:peppermintContact.communicationChannel];
                recentContact.avatarImageData = UIImageJPEGRepresentation(peppermintContact.avatarImage, 1);
            }
        }
        
        NSError *err = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(err) {
                [weakSelf.delegate operationFailure:err];
            } else {
                [weakSelf.delegate recentPeppermintContactsSavedSucessfully:peppermintContactArray];
            }
        });
    });
}


-(NSPredicate*) recentContactPredicate:(PeppermintContact*) peppermintContact {
    return [ContactsModel contactPredicateWithCommunicationChannelAddress:peppermintContact.communicationChannelAddress communicationChannel:peppermintContact.communicationChannel];
}


-(void) promtMultipleRecordsWithSameValueErrorForPeppermintContact:(PeppermintContact*)peppermintContact {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"nameSurname",peppermintContact.nameSurname,
                                  @"communicationChannelAddress", peppermintContact.communicationChannelAddress,
                                  @"communicationChannel", [NSNumber numberWithInt:peppermintContact.communicationChannel],
                                  nil];
        NSString *domain = @"More than one object exists in Db with same predicate";
        NSLog(@"%@", domain);
        NSError *err = [NSError errorWithDomain:domain code:-1 userInfo:userInfo];
        [self.delegate operationFailure:err];
    });
}

-(void) refreshRecentContactList {
    activeServiceCallCount ++;
    weakself_create();
    dispatch_async(DBQueue, ^{
        strongSelf_create();
        if(strongSelf) {
            Repository *repository = [Repository beginTransaction];
            NSArray *recentContactsArray = [repository getResultsFromEntity:[RecentContact class] predicateOrNil:nil ascSortStringOrNil:nil descSortStringOrNil:nil];
            
            //Sort Descending
            recentContactsArray = [recentContactsArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                RecentContact *first = (RecentContact*)a;
                RecentContact *second = (RecentContact*)b;
                
                NSDate *firstMaxDate = [NSDate maxOfDate1:first.peppermintContactDate date2:first.mailClientContactDate];
                NSDate *secondMaxDate = [NSDate maxOfDate1:second.peppermintContactDate date2:second.mailClientContactDate];
                return [secondMaxDate compare:firstMaxDate];
            }];
            
            NSMutableArray *recentPeppermintContacts = [NSMutableArray new];
#if (TARGET_OS_WATCH)
            NSMutableArray * recentPeppermintContactsData = [NSMutableArray new];
#endif
            receivedMessagesEmailSet = [ChatEntryModel receivedMessagesEmailSet];
            for(RecentContact *recentContact in recentContactsArray) {
                PeppermintContact * ppm_contact = [strongSelf peppermintContactWithRecentContact:recentContact];
                NSArray *unreadAudioMessages = [repository getResultsFromEntity:[ChatEntry class]
                                                            predicateOrNil:
                                           [ChatEntryModel unreadAudioMessagesPredicateForEmail:ppm_contact.communicationChannelAddress]];
                ppm_contact.unreadAudioMessageCount = unreadAudioMessages.count;
                
                [recentPeppermintContacts addObject:ppm_contact];
#if (TARGET_OS_WATCH)
                [recentPeppermintContactsData addObject:[ppm_contact archivedRootData]];
#endif
            }
            
#if (TARGET_OS_WATCH)
            if (NSClassFromString(@"WCSession") && recentPeppermintContactsData.count > 0) {
                if ([WCSession isSupported]) {
                    NSError * err;
                    [[WCSession defaultSession] updateApplicationContext:@{@"contact":recentPeppermintContactsData} error:&err];
                    if (err) {
                        NSLog(@"%s: %@", __PRETTY_FUNCTION__, err);
                    }
                }
            }
#endif
            
            if(--activeServiceCallCount==0) {
                peppermintMessageRecentContactsArray = nil;
                mailClientMessageRecentContactsArray = nil;
                contactList = recentPeppermintContacts;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.delegate recentPeppermintContactsRefreshed];
                });
            } else {
                NSLog(@"Did not complete refresh, cos another refresh call is active!");
            }
        }
    });
}

- (PeppermintContact*) peppermintContactWithRecentContact:(RecentContact*) recentContact {
    PeppermintContact *peppermintContact = [[PeppermintContact alloc] initWithContact:recentContact];
    peppermintContact.hasReceivedMessageOverPeppermint = [receivedMessagesEmailSet containsObject:peppermintContact.communicationChannelAddress];
    peppermintContact.lastMailClientContactDate = recentContact.mailClientContactDate;
    peppermintContact.lastPeppermintContactDate = recentContact.peppermintContactDate;
    return peppermintContact;
}

#pragma mark - Contact List Functions

-(NSMutableArray*) allMessageRecentContactsArray {
    return contactList;
}

-(NSMutableArray*) peppermintMessageRecentContactsArray {
    if(!peppermintMessageRecentContactsArray) {
        NSPredicate *havingPeppermintMessagePredicate = [NSPredicate predicateWithFormat:@"self.lastPeppermintContactDate != nil"];
        NSArray *unsortedArray = [contactList filteredArrayUsingPredicate:havingPeppermintMessagePredicate];
        NSArray *sortedArray = [unsortedArray sortedArrayUsingDescriptors: @[[NSSortDescriptor sortDescriptorWithKey:@"lastPeppermintContactDate" ascending:NO]]];
        peppermintMessageRecentContactsArray = [NSMutableArray arrayWithArray:sortedArray];
    }
    return peppermintMessageRecentContactsArray;
}

-(NSMutableArray*) mailClientMessageRecentContactsArray {
    if(!mailClientMessageRecentContactsArray) {
        NSPredicate *havingMailClientMessagePredicate = [NSPredicate predicateWithFormat:@"self.lastMailClientContactDate != nil"];
        NSArray *unsortedArray = [contactList filteredArrayUsingPredicate:havingMailClientMessagePredicate];
        NSArray *sortedArray = [unsortedArray sortedArrayUsingDescriptors: @[[NSSortDescriptor sortDescriptorWithKey:@"lastMailClientContactDate" ascending:NO]]];
        mailClientMessageRecentContactsArray = [NSMutableArray arrayWithArray:sortedArray];
    }
    return mailClientMessageRecentContactsArray;
}

@end
