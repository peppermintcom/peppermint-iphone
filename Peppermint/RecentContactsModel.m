//
//  RecentContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 10/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecentContactsModel.h"

@import WatchConnectivity;

#define DBQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

@implementation RecentContactsModel

-(id) init {
    self = [super init];
    if(self) {
        self.contactList = [NSMutableArray new];
    }
    return self;
}

//- (void)migrateContactsFromUserDefaults {
//  NSMutableArray * array = [[[NSUserDefaults standardUserDefaults] objectForKey:@"recentContacts"] mutableCopy];
//
//  for (NSData * peppermintContactData in array) {
//    PeppermintContact * ppm_c = [PeppermintContact peppermintContactWithData:peppermintContactData];
//    [self save:ppm_c];
//  }
//}
//
//- (void)saveInUserDefaults:(NSData *)peppermintContact {
//  NSMutableArray * array = [[[NSUserDefaults standardUserDefaults] objectForKey:@"recentContacts"] mutableCopy];
//  if (!array) {
//    array = [NSMutableArray array];
//  }
//  
//  [array addObject:peppermintContact];
//  [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"recentContacts"];
//}

-(void) save:(PeppermintContact*) peppermintContact {
    dispatch_async(DBQueue, ^() {
#if !(TARGET_OS_WATCH)
      if (NSClassFromString(@"WCSession")) {
        if ([WCSession isSupported]) {
          NSError * err;
          //[[WCSession defaultSession] updateApplicationContext:@{@"contact":@[[peppermintContact archivedRootData]]} error:&err];
          if (err) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, err);
          }
        }
      }
#endif
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
    return [NSPredicate predicateWithFormat:@"self.nameSurname CONTAINS %@ AND self.communicationChannelAddress CONTAINS %@ AND self.communicationChannel = %@ ",
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
    PeppermintContact *peppermintContact = [self peppermintContactWithRecentContact:recentContact];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(err) {
            [self.delegate operationFailure:err];
        } else {
            [self.delegate recentPeppermintContactSavedSucessfully:peppermintContact];
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
          if ([self.delegate respondsToSelector:@selector(operationFailure:)]) {
            [self.delegate operationFailure:err];
          }
        } else {
          if ([self.delegate respondsToSelector:@selector(recentPeppermintContactSavedSucessfully:)]) {
            [self.delegate recentPeppermintContactSavedSucessfully:peppermintContact];
          }
        }
    });
}

-(void) refreshRecentContactList {
    dispatch_async(DBQueue, ^{
        Repository *repository = [Repository beginTransaction];
        NSArray *recentContactsArray = [repository getResultsFromEntity:[RecentContact class] predicateOrNil:nil ascSortStringOrNil:nil descSortStringOrNil:[NSArray arrayWithObjects:@"contactDate", nil]];
        
        NSMutableArray *recentPeppermintContacts = [NSMutableArray new];
      NSMutableArray * recentPeppermintContactsData = [NSMutableArray new];
        for (RecentContact *recentContact in recentContactsArray) {
          PeppermintContact * ppm_contact = [self peppermintContactWithRecentContact:recentContact];
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

        self.contactList = recentPeppermintContacts;
        
        dispatch_async(dispatch_get_main_queue(), ^{
          if ([self.delegate respondsToSelector:@selector(recentPeppermintContactsRefreshed)]) {
            [self.delegate recentPeppermintContactsRefreshed];
          }
        });
    });
}

- (PeppermintContact*) peppermintContactWithRecentContact:(RecentContact*) recentContact {
    PeppermintContact *peppermintContact = [PeppermintContact new];
    peppermintContact.avatarImage = [UIImage imageWithData:recentContact.avatarImageData];
    peppermintContact.nameSurname = recentContact.nameSurname;
    peppermintContact.communicationChannelAddress = recentContact.communicationChannelAddress;
    peppermintContact.communicationChannel = !recentContact.communicationChannel ? -1 : recentContact.communicationChannel.intValue;
    return peppermintContact;
}

@end
