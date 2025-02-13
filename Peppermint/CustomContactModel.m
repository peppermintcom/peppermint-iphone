//
//  CustomContactModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 04/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "CustomContactModel.h"
#import "PeppermintContact.h"
#import "Repository.h"
#import "ContactsModel.h"

@implementation CustomContactModel

-(NSPredicate*) peppermintContactPredicateWithNameSurname:(NSString*) nameSurname communicationChanneldAddress:(NSString*)communicationChannelAddress communicationChannel:(CommunicationChannel) communicationChannel {
    
    NSPredicate *nameSurnamePredicate = [NSPredicate predicateWithFormat:@"self.nameSurname LIKE[cd] %@", nameSurname];
    NSPredicate *communicationChannelPredicate = [NSPredicate predicateWithFormat:@"self.communicationChannel = %@ ", [NSNumber numberWithInt:communicationChannel]];
    NSPredicate *communicationChannelAddressPredicate = [NSPredicate predicateWithFormat:@"self.communicationChannelAddress CONTAINS[cd] %@", communicationChannelAddress];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:nameSurnamePredicate, communicationChannelPredicate, communicationChannelAddressPredicate, nil]];
}

-(void) save:(PeppermintContact*) peppermintContact {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^() {
        Repository *repository = [Repository beginTransaction];
        [peppermintContact addToCoreSpotlightSearch];
        NSPredicate *predicate = [weakSelf peppermintContactPredicateWithNameSurname:peppermintContact.nameSurname communicationChanneldAddress:peppermintContact.communicationChannelAddress communicationChannel:peppermintContact.communicationChannel];
        NSArray *matchedCustomContacts = [repository getResultsFromEntity:[CustomContact class]
                                                           predicateOrNil:predicate];
        
        if(matchedCustomContacts.count == 0) {
            [weakSelf addNewCustomForPeppermintContact:peppermintContact inRepository:repository];
        } else {
            repository = nil;
            //NSLog(@"Did not save custom Peppermint Contact as it already exists. %@ - %@", peppermintContact.nameSurname, peppermintContact.communicationChannelAddress);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate customPeppermintContactSavedSucessfully:peppermintContact];
            });
            
            /*
            if (matchedCustomContacts.count == 1) {
                [weakSelf promtDuplicateRecord:peppermintContact];
            } else {
                [weakSelf promtMultipleRecordsWithSameValueErrorForPeppermintContact:peppermintContact];
            }
            */
        }
    });
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

-(void) promtDuplicateRecord:(PeppermintContact*) peppermintContact {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *errorMessage =
        [NSString stringWithFormat:LOC(@"Contact exists format", @"Description"), peppermintContact.communicationChannelAddress];
        
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"nameSurname",peppermintContact.nameSurname,
                                  @"communicationChannelAddress", peppermintContact.communicationChannelAddress,
                                  @"communicationChannel", [NSNumber numberWithInt:peppermintContact.communicationChannel],
                                  errorMessage, NSLocalizedDescriptionKey,
                                  nil];
        NSString *domain = @"This record already exists in Db";
        NSError *err = [NSError errorWithDomain:domain code:-1 userInfo:userInfo];
        [self.delegate operationFailure:err];
    });
}

-(void) addNewCustomForPeppermintContact:(PeppermintContact*) peppermintContact inRepository:(Repository*) repository {
    CustomContact *customContact = (CustomContact*)[repository createEntity:[CustomContact class]];
    customContact.nameSurname = peppermintContact.nameSurname;
    customContact.communicationChannelAddress = peppermintContact.communicationChannelAddress;
    customContact.communicationChannel = [NSNumber numberWithInt:peppermintContact.communicationChannel];
    customContact.avatarImageData = UIImageJPEGRepresentation(peppermintContact.avatarImage, 1);
    
    customContact.identifier = peppermintContact.uniqueContactId ? peppermintContact.uniqueContactId : [NSString stringWithFormat:@"%ld", peppermintContact.communicationChannelAddress.hash];
    NSError *err = [repository endTransaction];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(err) {
            [self.delegate operationFailure:err];
        } else {
            [self.delegate customPeppermintContactSavedSucessfully:peppermintContact];
        }
    });
}

#pragma mark - Fetch PeppermintContact Array

+(NSArray*) peppermintContactsArrayWithFilterText:(NSString*) filterText {
    
    NSMutableArray *peppermintContactArray = [NSMutableArray new];
    NSCompoundPredicate *communicationPredicate = nil;
    if(filterText.length > 0) {
        communicationPredicate =
        [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                       [ContactsModel contactPredicateWithNameSurname:filterText],
                                                       [ContactsModel contactPredicateWithCommunicationChannelAddress:filterText],
                                                       nil]];
    }
    
    Repository *repository = [Repository beginTransaction];
    NSArray *matchingCustomContacts = [repository getResultsFromEntity:[CustomContact class] predicateOrNil:communicationPredicate];
    
    for(CustomContact *matchedCustomContact in matchingCustomContacts) {
        PeppermintContact *peppermintContact = [[PeppermintContact alloc] initWithContact:matchedCustomContact];
        peppermintContact.uniqueContactId = [NSString stringWithFormat:@"%@%lu",
                                             CONTACT_CUSTOM, matchedCustomContact.identifier.hash];
        [peppermintContactArray addObject:peppermintContact];
    }
    [repository endTransaction];
    return peppermintContactArray;
}

@end