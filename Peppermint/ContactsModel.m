//
//  ContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsModel.h"

#if !(TARGET_OS_WATCH)
#import "GoogleContactsModel.h"
#import "CustomContactModel.h"
#import "ChatModel.h"
#endif


#define ContactsOperationQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

@implementation ContactsModel
#if !(TARGET_OS_WATCH)
{
    volatile NSUInteger loadContactsTriggerCount;
    NSCharacterSet *unwantedCharsSet;
    NSArray *emailContactList;
    NSArray *smsContactList;
    NSMutableSet *uniqueContactIdsToRemoveMutableSet;
    NSArray *nonFilteredContactsArray;
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
        self.contactList = [NSMutableArray new];
        self.filterText = @"";
        loadContactsTriggerCount = 0;
        unwantedCharsSet = [[NSCharacterSet characterSetWithCharactersInString:CHARS_FOR_PHONE] invertedSet];
        uniqueContactIdsToRemoveMutableSet = [NSMutableSet new];
        nonFilteredContactsArray = [NSArray new];
    }
    return self;
}

-(void) setup {
    [self checkForAddressBookPermission];
}

-(void) checkForAddressBookPermission {
    switch([APAddressBook access])
    {
        case APAddressBookAccessUnknown:
            [self requestAccessForAddressBook];
            break;
        case APAddressBookAccessDenied:
            [self.delegate contactsAccessRightsAreNotSupplied];
            [self initAPAddressBook];
            break;
        case APAddressBookAccessGranted:
            [self initAPAddressBook];
            break;
    }
}

-(void) requestAccessForAddressBook {
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        
        NSError *err = (__bridge NSError*)error;
        if(err) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate operationFailure:err];
            });
        } else if (!granted) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate contactsAccessRightsAreNotSupplied];
            });
            [self initAPAddressBook];
        } else {
            [self initAPAddressBook];
        }
    });
}

-(void) initAPAddressBook {
    addressBook = [[APAddressBook alloc] init];
    addressBook.fieldsMask =
        APContactFieldCompositeName
        | APContactFieldPhones
        | APContactFieldEmails
        | APContactFieldThumbnail
        | APContactFieldRecordID;
    addressBook.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]];
    addressBook.filterBlock = ^BOOL(APContact *contact) {
        NSMutableString *searchString = [NSMutableString stringWithFormat:@"%@", contact.compositeName];
        for(NSString *phone in contact.phones) {
            [searchString appendFormat:@";%@", phone];
        }
        for(NSString *email in contact.emails) {
            [searchString appendFormat:@";%@", email];
        }
        
        BOOL containsText = [searchString rangeOfString:self.filterText.trimmedText options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].length > 0;
        
        return
        (contact.phones.count > 0 ||
         contact.emails.count > 0)
        && ( self.filterText.length == 0 || containsText);
    };
    [self refreshContactList];
}

-(NSString*)filterUnwantedChars:(NSString*) communicationChannelAddress {
    NSString *filteredCommunicationChannelAddress = [[communicationChannelAddress componentsSeparatedByCharactersInSet:unwantedCharsSet] componentsJoinedByString:@""];
    return filteredCommunicationChannelAddress;
}

-(void) refreshContactList {
    
    /*
     *  Load Contacts trigger count variable prevents multiple calls to the APAddressBook framework
     *  during a query is continuing.
     */
    
    
    #warning "loadContactsTriggerCount approach works nice! However it may cause more service calls than needed. Refactor code for not making a service call when another call is in progress."
    ++loadContactsTriggerCount;
    weakself_create();
    [addressBook loadContactsOnQueue:ContactsOperationQueue completion:
     ^(NSArray *contacts, NSError *error)
     {
         NSMutableArray *peppermintContactsArray = [NSMutableArray new];
         if(error) {
             [self.delegate operationFailure:error];
         } else {
             NSMutableSet *uniqueSet = [NSMutableSet new];
             for(APContact *contact in contacts) {
                 NSString *nameSurname = contact.compositeName;
                 if(!nameSurname) {
                     NSMutableArray *communicationChannels = [NSMutableArray new];
                     [communicationChannels addObjectsFromArray:contact.phones];
                     [communicationChannels addObjectsFromArray:contact.emails];
                     for (NSString *communicationChannel in communicationChannels) {
                         nameSurname = communicationChannel;
                     }
                 }
                 
                 if(nameSurname) {
                     nameSurname = [nameSurname capitalizedString];
                     for(NSString *email in contact.emails) {
                         NSString *key = [NSString stringWithFormat:@"%@,%@", nameSurname, email];
                         if(self.filterText.length > 0 && ![key.lowercaseString containsString:self.filterText.lowercaseString]) {
                             continue;
                         } else if([uniqueSet containsObject:key]) {
                             continue;
                         } else {
                             [uniqueSet addObject:key];
                             PeppermintContact *peppermintContact = [PeppermintContact new];
                             peppermintContact.uniqueContactId = [NSString stringWithFormat:@"%@%@",
                                                                  CONTACT_PHONEBOOK,contact.recordID];
                             peppermintContact.communicationChannel = CommunicationChannelEmail;
                             peppermintContact.communicationChannelAddress = email;
                             peppermintContact.nameSurname = nameSurname;
                             peppermintContact.avatarImage = contact.thumbnail;
                             [peppermintContactsArray addObject:peppermintContact];
                         }
                     }
                     
                     for(NSString *rawPhone in contact.phones) {
                         NSString *phone = [self filterUnwantedChars:rawPhone];
                         if(phone.length > 0) {
                             NSString *key = [NSString stringWithFormat:@"%@,%@", nameSurname, phone];
                             if(self.filterText.length > 0 && ![key.lowercaseString containsString:self.filterText.lowercaseString]) {
                                 continue;
                             } else if([uniqueSet containsObject:key]) {
                                 continue;
                             } else {
                                 [uniqueSet addObject:key];
                             }
                             PeppermintContact *peppermintContact = [PeppermintContact new];
                             peppermintContact.uniqueContactId = [NSString stringWithFormat:@"%@%@",
                                                                  CONTACT_PHONEBOOK,contact.recordID];
                             peppermintContact.communicationChannel = CommunicationChannelSMS;
                             peppermintContact.communicationChannelAddress = phone;
                             peppermintContact.nameSurname = nameSurname;
                             peppermintContact.avatarImage = contact.thumbnail;
                             [peppermintContactsArray addObject:peppermintContact];
                         }
                     }
                 }
             }
         }
         
         if(--loadContactsTriggerCount != 0) {
             loadContactsTriggerCount = 0;
             dispatch_sync(dispatch_get_main_queue(), ^{
                 [self refreshContactList];
             });
         } else {
             [weakSelf callContactsDelegateWithArray:peppermintContactsArray];
         }
     }];
}

-(void) callContactsDelegateWithArray:(NSArray*)contactsFromContacBook {
    
    NSMutableArray *peppermintContactsArray = [NSMutableArray new];
    
    //ContactBook Contacts
    [peppermintContactsArray addObjectsFromArray:contactsFromContacBook];
    
    //Google Contacts
    NSArray *googleContactsArray =
    [GoogleContactsModel peppermintContactsArrayWithFilterText:self.filterText.trimmedText];
    [peppermintContactsArray addObjectsFromArray:googleContactsArray];
    
    //CustomContacts
    NSArray *customContactsArray =
    [CustomContactModel peppermintContactsArrayWithFilterText:self.filterText.trimmedText];
    [peppermintContactsArray addObjectsFromArray:customContactsArray];
    
    //Unify for via Peppermint
    peppermintContactsArray = [self mergeContactsConsideringViaPeppermint:peppermintContactsArray];
    
    self.contactList = peppermintContactsArray;
    NSArray *sortedList = [self.contactList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(PeppermintContact*)a nameSurname];
        NSString *second = [(PeppermintContact*)b nameSurname];
        return [first.lowercaseString compare:second.lowercaseString];
    }];
    self.contactList = [NSMutableArray arrayWithArray:sortedList];
    
    emailContactList = smsContactList = nil;
    if(self.filterText.trimmedText.length == 0) {
        nonFilteredContactsArray = [NSArray arrayWithArray:self.contactList];
        dispatch_async(LOW_PRIORITY_QUEUE, ^{
            for(PeppermintContact *peppermintContact in nonFilteredContactsArray) {
                [peppermintContact addToCoreSpotlightSearch];
            }
        });
    }
    weakself_create();
    dispatch_sync(dispatch_get_main_queue(), ^{
        [weakSelf.delegate contactListRefreshed];
    });
    
}

-(NSArray*) emailContactList {
    if(emailContactList == nil) {
        emailContactList = [self.contactList filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:
                             @"self.communicationChannel == %d", CommunicationChannelEmail]];
    }
    return emailContactList;
}

-(NSArray*) smsContactList {
    if(smsContactList == nil) {
        smsContactList = [self.contactList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.communicationChannel == %d", CommunicationChannelSMS]];
    }
    return smsContactList;
}

#pragma mark - Merge Contacts to show via Peppermint

-(NSMutableArray*) mergeContactsConsideringViaPeppermint:(NSMutableArray*) currentPeppermintContactsArray {
    NSSet *receivedMessagesEmailSet = [ChatModel receivedMessagesEmailSet];
    
    for(PeppermintContact *peppermintContact in currentPeppermintContactsArray) {
        if([receivedMessagesEmailSet containsObject:peppermintContact.communicationChannelAddress]) {
            peppermintContact.hasReceivedMessageOverPeppermint = YES;
            [uniqueContactIdsToRemoveMutableSet addObject:peppermintContact.uniqueContactId];
        }
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.hasReceivedMessageOverPeppermint == %@ OR NOT(self.uniqueContactId IN %@)", @YES, uniqueContactIdsToRemoveMutableSet];
    NSArray *filteredArray = [currentPeppermintContactsArray filteredArrayUsingPredicate:predicate];
    filteredArray  = [[NSSet setWithArray:filteredArray] allObjects];    
    return [NSMutableArray arrayWithArray:filteredArray];
}


#pragma mark - Match PeppermintContact for Email&Name

-(PeppermintContact*) matchingPeppermintContactForEmail:(NSString*) email nameSurname:(NSString*) nameSurname {
    PeppermintContact *peppermintContact = nil;
    NSPredicate *contactPredicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:email];
    NSArray *filteredContactsArray = [nonFilteredContactsArray filteredArrayUsingPredicate:contactPredicate];
    if(filteredContactsArray.count > 0) {
        peppermintContact = filteredContactsArray.firstObject;
    } else {
        nameSurname = (nameSurname.trimmedText.length == 0) ? email : nameSurname;
        peppermintContact = [PeppermintContact new];
        peppermintContact.communicationChannel = CommunicationChannelEmail;
        peppermintContact.nameSurname = nameSurname;
        peppermintContact.communicationChannelAddress = email;
    }    
    return peppermintContact;
}

#endif

#pragma mark - Contacts CoreData

+(NSPredicate*) contactPredicateWithNameSurname:(NSString*) nameSurname {
    return [NSPredicate predicateWithFormat:@"self.nameSurname CONTAINS[cd] %@",
            nameSurname];
}

+(NSPredicate*) contactPredicateWithCommunicationChannel:(CommunicationChannel) communicationChannel {
    return [NSPredicate predicateWithFormat:@"self.communicationChannel = %@ ", [NSNumber numberWithInt:communicationChannel]];
}

+(NSPredicate*) contactPredicateWithCommunicationChannelAddress:(NSString *)communicationChannelAddress {
    return [NSPredicate predicateWithFormat:@"self.communicationChannelAddress CONTAINS[cd] %@", communicationChannelAddress];
}

+(NSPredicate*) contactPredicateWithNameSurname:(NSString*) nameSurname communicationChannel:(CommunicationChannel)communicationChannel
{
    NSPredicate* namePredicate = [self contactPredicateWithNameSurname:nameSurname];
    NSPredicate* communicationChannelPredicate = [self contactPredicateWithCommunicationChannel:communicationChannel];
    return [NSCompoundPredicate andPredicateWithSubpredicates:
            [NSArray arrayWithObjects:namePredicate, communicationChannelPredicate, nil]];
}

+(NSPredicate*) contactPredicateWithCommunicationChannelAddress:(NSString*)communicationChannelAddress communicationChannel:(CommunicationChannel)communicationChannel
{
    NSPredicate* communicationChannelPredicate = [self contactPredicateWithCommunicationChannel:communicationChannel];
    NSPredicate* communicationChannelAddressPredicate = [self contactPredicateWithCommunicationChannelAddress:communicationChannelAddress];
    return [NSCompoundPredicate andPredicateWithSubpredicates:
            [NSArray arrayWithObjects:communicationChannelPredicate, communicationChannelAddressPredicate, nil]];
}

+(NSPredicate*) contactPredicateWithNameSurname:(NSString*) nameSurname communicationChannelAddress:(NSString*)communicationChannelAddress communicationChannel:(CommunicationChannel)communicationChannel
{
    NSPredicate* namePredicate = [self contactPredicateWithNameSurname:nameSurname];
    NSPredicate* mailPredicate = [self contactPredicateWithCommunicationChannelAddress:communicationChannelAddress communicationChannel:communicationChannel];
    return [NSCompoundPredicate andPredicateWithSubpredicates:
            [NSArray arrayWithObjects:namePredicate, mailPredicate, nil]];
}

+(NSPredicate*) contactPredicateWithNameSurnameMatchExact:(NSString*) nameSurname communicationChannel:(CommunicationChannel)communicationChannel
{
    NSPredicate* nameExactMatchPredicate = [NSPredicate predicateWithFormat:@"self.nameSurname ==[cd] %@", nameSurname];
    NSPredicate* communicationChannelPredicate = [self contactPredicateWithCommunicationChannel:communicationChannel];
    return [NSCompoundPredicate andPredicateWithSubpredicates:
            [NSArray arrayWithObjects: nameExactMatchPredicate, communicationChannelPredicate, nil]];
}



@end
