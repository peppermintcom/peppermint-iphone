//
//  ContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsModel.h"
#import "GoogleContactsModel.h"
#import "CustomContactModel.h"

#define ContactsOperationQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

@implementation ContactsModel {
    volatile NSUInteger loadContactsTriggerCount;
    NSCharacterSet *unwantedCharsSet;
    NSArray *emailContactList;
    NSArray *smsContactList;
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
        | APContactFieldThumbnail;
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
     if(++loadContactsTriggerCount == 1) {
         
         [addressBook loadContactsOnQueue:ContactsOperationQueue completion:
          ^(NSArray *contacts, NSError *error)
         {
             if(error) {
                 [self.delegate operationFailure:error];
             } else {
                 NSMutableSet *uniqueSet = [NSMutableSet new];
                 NSMutableArray *peppermintContactsArray = [NSMutableArray new];
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
                                 peppermintContact.communicationChannel = CommunicationChannelEmail;
                                 peppermintContact.communicationChannelAddress = email;
                                 peppermintContact.nameSurname = nameSurname;
                                 peppermintContact.avatarImage = contact.thumbnail;
                                 [peppermintContactsArray addObject:peppermintContact];
                             }
                         }

                         for(NSString *rawPhone in contact.phones) {
                             NSString *phone = [self filterUnwantedChars:rawPhone];
                             NSString *key = [NSString stringWithFormat:@"%@,%@", nameSurname, phone];
                             if(self.filterText.length > 0 && ![key.lowercaseString containsString:self.filterText.lowercaseString]) {
                                 continue;
                             } else if([uniqueSet containsObject:key]) {
                                 continue;
                             } else {
                                 [uniqueSet addObject:key];
                             }
                             PeppermintContact *peppermintContact = [PeppermintContact new];
                             peppermintContact.communicationChannel = CommunicationChannelSMS;
                             peppermintContact.communicationChannelAddress = phone;
                             peppermintContact.nameSurname = nameSurname;
                             peppermintContact.avatarImage = contact.thumbnail;
                             [peppermintContactsArray addObject:peppermintContact];
                         }
                     }
                 }
                 
                 //Google Contacts
                 NSArray *googleContactsArray =
                 [GoogleContactsModel peppermintContactsArrayWithFilterText:self.filterText.trimmedText];
                 [peppermintContactsArray addObjectsFromArray:googleContactsArray];
                 
                 //CustomContacts
                 NSArray *customContactsArray =
                 [CustomContactModel peppermintContactsArrayWithFilterText:self.filterText.trimmedText];
                 [peppermintContactsArray addObjectsFromArray:customContactsArray];
                 
                 self.contactList = peppermintContactsArray;
                 NSArray *sortedList = [self.contactList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                     NSString *first = [(PeppermintContact*)a nameSurname];
                     NSString *second = [(PeppermintContact*)b nameSurname];
                     return [first.lowercaseString compare:second.lowercaseString];
                 }];
                 self.contactList = [NSMutableArray arrayWithArray:sortedList];
                 
                 dispatch_async(LOW_PRIORITY_QUEUE, ^{
                     for(PeppermintContact *peppermintContact in self.contactList) {
                         [peppermintContact addToCoreSpotlightSearch];
                     }
                 });
                 
                 emailContactList = smsContactList = nil;
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     [self.delegate contactListRefreshed];
                 });
             }
             
             if(--loadContactsTriggerCount > 0) {
                 //NSLog(@"Load contacts method is recalled %lu times during the previous query", (unsigned long)loadContactsTriggerCount);
                 loadContactsTriggerCount = 0;
                 dispatch_sync(dispatch_get_main_queue(), ^{
                     [self refreshContactList];
                 });
             }
         }];
     }
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

@end
