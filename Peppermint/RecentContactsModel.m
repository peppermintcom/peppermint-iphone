//
//  RecentContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 10/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecentContactsModel.h"

//#define DBQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
#define DBQueue dispatch_get_main_queue()

@implementation RecentContactsModel

-(void) saveAsync:(PeppermintContact*) peppermintContact {
    dispatch_async(DBQueue, ^() {
        Repository *repository = [Repository beginTransaction];
        NSArray *matchedRecentContacts = [repository getResultsFromEntity:[RecentContact class] predicateOrNil:[self recentContactPredicate:peppermintContact]];
        
        if(matchedRecentContacts.count > 1) {
            repository = nil;
            [self promtMultipleRecordsWithSameValueErrorForPeppermintContact:peppermintContact];
        } else if (matchedRecentContacts.count == 1) {
            RecentContact *recentContact = [matchedRecentContacts objectAtIndex:0];
            [self updateRecentContact:recentContact inRepository:repository];
        } else if (matchedRecentContacts.count == 0) {
            [self addNewRecentForPeppermintContact:peppermintContact inRepository:repository];
        }
    });
}

-(NSPredicate*) recentContactPredicate:(PeppermintContact*) peppermintContact {

    return [NSPredicate predicateWithFormat:@"self.nameSurname MATCHES %@ AND self.communicationChannelAddress MATCHES %@ AND self.communicationChannel = %@ ",
            peppermintContact.nameSurname,
            peppermintContact.communicationChannelAddress,
            [NSNumber numberWithInt:peppermintContact.communicationChannel]
            ];
}

-(void) promtMultipleRecordsWithSameValueErrorForPeppermintContact:(PeppermintContact*)peppermintContact {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"nameSurname",peppermintContact.nameSurname,
                                  @"communicationChannelAddress", peppermintContact.communicationChannelAddress,
                                  @"communicationChannel", [NSNumber numberWithInt:peppermintContact.communicationChannel],
                                  nil];
        NSString *domain = @"More than one object exists in Db with same predicate";
        NSError *err = [NSError errorWithDomain:domain code:-1 userInfo:userInfo];
        [self.delegate operationFailure:err];
    });
}

-(void) updateRecentContact:(RecentContact*) recentContact inRepository:(Repository*) repository {
    recentContact.contactDate = [NSDate new];
    NSError *err = [repository endTransaction];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(err) {
            [self.delegate operationFailure:err];
        } else {
            [self.delegate recentContactSavedSucessfully:recentContact];
        }
    });
}

-(void) addNewRecentForPeppermintContact:(PeppermintContact*) peppermintContact inRepository:(Repository*) repository {
    RecentContact *recentContact = (RecentContact*)[repository createEntity:[RecentContact class]];
    recentContact.contactDate = [NSDate new];
    recentContact.nameSurname = peppermintContact.nameSurname;
    recentContact.communicationChannelAddress = peppermintContact.communicationChannelAddress;
    recentContact.communicationChannel = [NSNumber numberWithInt:peppermintContact.communicationChannel];
    recentContact.avatarImageData = UIImagePNGRepresentation(peppermintContact.avatarImage);
    NSError *err = [repository endTransaction];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(err) {
            [self.delegate operationFailure:err];
        } else {
            [self.delegate recentContactSavedSucessfully:recentContact];
        }
    });
}

-(void) getRecentContactsAsync {
    dispatch_async(DBQueue, ^{
        Repository *repository = [Repository beginTransaction];
        NSArray *recentContactsArray = [repository getResultsFromEntity:[RecentContact class] predicateOrNil:nil ascSortStringOrNil:nil descSortStringOrNil:[NSArray arrayWithObjects:@"contactDate", nil]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate recentContactsQueried:recentContactsArray];
        });
    });
}

@end
