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
#import "ChatEntryModel.h"
#import "Repository.h"
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
    BOOL isSportLightSearchRegistered;
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
        isSportLightSearchRegistered = YES;
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
                             peppermintContact.uniqueContactId = [NSString stringWithFormat:@"%@%d",
                                                                  CONTACT_PHONEBOOK,contact.recordID.hash];
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
                             peppermintContact.uniqueContactId = [NSString stringWithFormat:@"%@%d",
                                                                  CONTACT_PHONEBOOK,contact.recordID.hash];
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
         
         BOOL gotNewRequestWhileOperating = --loadContactsTriggerCount > 0;
         BOOL processOperation = loadContactsTriggerCount == 0;
         loadContactsTriggerCount = 0;         
         if(gotNewRequestWhileOperating) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf refreshContactList];
             });
         } else if (processOperation) {
             [weakSelf callContactsDelegateWithArray:peppermintContactsArray];
         }
     }];
}

-(void) callContactsDelegateWithArray:(NSArray*)contactsFromContacBook {
    
    NSMutableArray *peppermintContactsArray = [NSMutableArray new];
    
    //Google Contacts
    NSArray *googleContactsArray =
    [GoogleContactsModel peppermintContactsArrayWithFilterText:self.filterText.trimmedText];
    [peppermintContactsArray addObjectsFromArray:googleContactsArray];
    
    //ContactBook Contacts
    [peppermintContactsArray addObjectsFromArray:contactsFromContacBook];
    
    //CustomContacts
    NSArray *customContactsArray =
    [CustomContactModel peppermintContactsArrayWithFilterText:self.filterText.trimmedText];
    [peppermintContactsArray addObjectsFromArray:customContactsArray];
    
    //Unify SMS Contacts
    peppermintContactsArray = [self unifySMSContacts:peppermintContactsArray];
    
    //Unify for via Peppermint
    peppermintContactsArray = [self mergeContactsConsideringViaPeppermint:peppermintContactsArray];
    
    NSArray *resultArray = [[NSSet setWithArray:peppermintContactsArray] allObjects];
    self.contactList = [NSMutableArray arrayWithArray:resultArray];
    
    NSArray *sortedList = [self.contactList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(PeppermintContact*)a nameSurname];
        NSString *second = [(PeppermintContact*)b nameSurname];
        BOOL firstReceived = [(PeppermintContact*)a hasReceivedMessageOverPeppermint];
        BOOL secondReceived = [(PeppermintContact*)b hasReceivedMessageOverPeppermint];
        BOOL filterTextExists = self.filterText.length > 0;
        
        NSComparisonResult result = NSOrderedSame;
        if(filterTextExists && firstReceived && !secondReceived) {
            result = NSOrderedAscending;
        } else if (filterTextExists && !firstReceived && secondReceived) {
            result = NSOrderedDescending;
        } else {
            result = [first.lowercaseString compare:second.lowercaseString];
        }
        return result;
    }];
    self.contactList = [NSMutableArray arrayWithArray:sortedList];
    
    emailContactList = smsContactList = nil;
    if(self.filterText.trimmedText.length == 0 && !isSportLightSearchRegistered) {
        isSportLightSearchRegistered = YES;
        dispatch_async(LOW_PRIORITY_QUEUE, ^{
            NSArray *nonFilteredContactsArray = [NSArray arrayWithArray:self.contactList];
            for(PeppermintContact *peppermintContact in nonFilteredContactsArray) {
                [peppermintContact addToCoreSpotlightSearch];
                NSLog(@"addToCoreSpotlightSearch");
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
        NSPredicate *emailPredicate = [ContactsModel contactPredicateWithCommunicationChannel:CommunicationChannelEmail];
        emailContactList = [self.contactList filteredArrayUsingPredicate:emailPredicate];
    }
    return emailContactList;
}

-(NSArray*) smsContactList {
    if(smsContactList == nil) {
        NSPredicate *smsPredicate = [ContactsModel contactPredicateWithCommunicationChannel:CommunicationChannelSMS];
        smsContactList = [self.contactList filteredArrayUsingPredicate:smsPredicate];
    }
    return smsContactList;
}

#pragma mark - Unify SMS Contacts

-(NSMutableArray*) unifySMSContacts:(NSMutableArray*) peppermintContactsArray {
    for(PeppermintContact *peppermintContact in peppermintContactsArray) {
        if(peppermintContact.communicationChannel == CommunicationChannelSMS) {
            peppermintContact.communicationChannelAddress = peppermintContact.nameSurname; //To merge SMS contacts with same name surname
            peppermintContact.explanation = LOC(@"...", @"No SMS Number Text");
        }
    }
    return peppermintContactsArray;
}

#pragma mark - Merge Contacts to show via Peppermint

-(NSMutableArray*) mergeContactsConsideringViaPeppermint:(NSMutableArray*) peppermintContactsArray {
    NSArray *currentPeppermintContactsArray = [NSArray arrayWithArray:peppermintContactsArray];
    NSSet *receivedMessagesEmailSet = [ChatEntryModel receivedMessagesEmailSet];
    
    NSPredicate *emailPredicate = [ContactsModel contactPredicateWithCommunicationChannel:CommunicationChannelEmail];
    NSArray *emailContactsArray = [peppermintContactsArray filteredArrayUsingPredicate:emailPredicate];
    NSMutableSet *emailContactsNameSurnameSet = [NSMutableSet new];
    for(PeppermintContact *peppermintContact in emailContactsArray) {
        [emailContactsNameSurnameSet addObject:peppermintContact.nameSurname];
    }
    
    for(PeppermintContact *peppermintContact in currentPeppermintContactsArray) {
        if([receivedMessagesEmailSet containsObject:peppermintContact.communicationChannelAddress]) {
            peppermintContact.hasReceivedMessageOverPeppermint = YES;
            [uniqueContactIdsToRemoveMutableSet addObject:peppermintContact.uniqueContactId];
        } else if([emailContactsNameSurnameSet containsObject:peppermintContact.nameSurname]
                  && peppermintContact.communicationChannel != CommunicationChannelEmail) {
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
    
    #warning "Consider to move repository operation to background."
    Repository *repository = [Repository beginTransaction];
    NSPredicate *predicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:email];
    NSArray *contactsArray = [repository getResultsFromEntity:[Contact class] predicateOrNil:predicate];
    if(contactsArray.count > 0) {
        Contact *contact = contactsArray.firstObject;
        peppermintContact = [[PeppermintContact alloc] initWithContact:contact];
    }
    
    if(!peppermintContact) {
        nameSurname = (nameSurname.trimmedText.length == 0) ? email : nameSurname;
        peppermintContact = [PeppermintContact new];
        peppermintContact.communicationChannel = CommunicationChannelEmail;
        peppermintContact.nameSurname = nameSurname;
        peppermintContact.communicationChannelAddress = email;
        peppermintContact.lastPeppermintContactDate = nil;
        peppermintContact.lastMailClientContactDate = nil;
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
