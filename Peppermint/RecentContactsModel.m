//
//  RecentContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 10/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecentContactsModel.h"
#import "ContactsModel.h"
#import "ChatModel.h"

@import WatchConnectivity;

#define DBQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

@implementation RecentContactsModel {
    NSSet *receivedMessagesEmailSet;
    __block int activeServiceCallCount;
}

-(id) init {
    self = [super init];
    if(self) {
        self.contactList = [NSMutableArray new];
        receivedMessagesEmailSet = nil;
        activeServiceCallCount = 0;
    }
    return self;
}

-(void) save:(PeppermintContact*) peppermintContact forContactDate:(NSDate*) contactDate {
    peppermintContact.lastMessageDate = contactDate;
    [self saveMultiple:[NSArray arrayWithObject:peppermintContact]];
}

-(void) saveMultiple:(NSArray<PeppermintContact*>*) peppermintContactArray {
    weakself_create();
    dispatch_async(DBQueue, ^() {
        Repository *repository = [Repository beginTransaction];
        
        for(PeppermintContact *peppermintContact in peppermintContactArray) {
            NSPredicate *predicate = [self recentContactPredicate:peppermintContact];
            NSArray *matchedRecentContacts = [repository getResultsFromEntity:[RecentContact class] predicateOrNil:predicate];
            
            RecentContact *recentContact = nil;
            if (matchedRecentContacts.count == 0) {
                recentContact = (RecentContact*)[repository createEntity:[RecentContact class]];
            } else if (matchedRecentContacts.count == 1) {
                recentContact = [matchedRecentContacts firstObject];
            } else {
                [weakSelf promtMultipleRecordsWithSameValueErrorForPeppermintContact:peppermintContact];
            }
            
            recentContact.contactDate = peppermintContact.lastMessageDate;
            recentContact.nameSurname = peppermintContact.nameSurname;
            recentContact.communicationChannelAddress = peppermintContact.communicationChannelAddress;
            recentContact.communicationChannel = [NSNumber numberWithInt:peppermintContact.communicationChannel];
            recentContact.avatarImageData = UIImageJPEGRepresentation(peppermintContact.avatarImage, 1);
        }
        
        NSError *err = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(err) {
                [self.delegate operationFailure:err];
            } else {
                [self.delegate recentPeppermintContactsSavedSucessfully:peppermintContactArray];
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
    dispatch_async(DBQueue, ^{
        Repository *repository = [Repository beginTransaction];
        NSArray *recentContactsArray = [repository getResultsFromEntity:[RecentContact class] predicateOrNil:nil ascSortStringOrNil:nil descSortStringOrNil:[NSArray arrayWithObjects:@"contactDate", nil]];
        
        NSMutableArray *recentPeppermintContacts = [NSMutableArray new];
        NSMutableArray * recentPeppermintContactsData = [NSMutableArray new];

        receivedMessagesEmailSet = [ChatModel receivedMessagesEmailSet];
        for(RecentContact *recentContact in recentContactsArray) {
            PeppermintContact * ppm_contact = [self peppermintContactWithRecentContact:recentContact];
            NSArray *unreadMessages = [repository getResultsFromEntity:[ChatEntry class]
                                                        predicateOrNil:
                                       [ChatModel unreadMessagesPredicateForEmail:ppm_contact.communicationChannelAddress]];
            ppm_contact.unreadMessageCount = unreadMessages.count;
            
            [recentPeppermintContacts addObject:ppm_contact];
#if !(TARGET_OS_WATCH)
            [recentPeppermintContactsData addObject:[ppm_contact archivedRootData]];
#endif
        }
        
        if (NSClassFromString(@"WCSession") && recentPeppermintContactsData.count > 0) {
            if ([WCSession isSupported]) {
                NSError * err;
                [[WCSession defaultSession] updateApplicationContext:@{@"contact":recentPeppermintContactsData} error:&err];
                if (err) {
                    NSLog(@"%s: %@", __PRETTY_FUNCTION__, err);
                }
            }
        }
        
        if(--activeServiceCallCount==0) {
            self.contactList = recentPeppermintContacts;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate recentPeppermintContactsRefreshed];
            });
        } else {
            NSLog(@"Did not complete refresh, cos another refresh call is active!");
        }
    });
}

- (PeppermintContact*) peppermintContactWithRecentContact:(RecentContact*) recentContact {
    PeppermintContact *peppermintContact = [PeppermintContact new];
    peppermintContact.avatarImage = [UIImage imageWithData:recentContact.avatarImageData];
    peppermintContact.nameSurname = recentContact.nameSurname;
    peppermintContact.communicationChannelAddress = recentContact.communicationChannelAddress;
    peppermintContact.communicationChannel = !recentContact.communicationChannel ? -1 : recentContact.communicationChannel.intValue;
    peppermintContact.hasReceivedMessageOverPeppermint = [receivedMessagesEmailSet containsObject:peppermintContact.communicationChannelAddress];
    peppermintContact.lastMessageDate = recentContact.contactDate;
    return peppermintContact;
}

@end
