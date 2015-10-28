//
//  ContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsModel.h"

#define ContactsOperationQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

@implementation ContactsModel {
    volatile NSUInteger loadContactsTriggerCount;
    NSArray *emailContactList;
    NSArray *smsContactList;
}

-(id) init {
    self = [super init];
    if(self) {
        self.contactList = [NSMutableArray new];
        self.filterText = @"";
        loadContactsTriggerCount = 0;
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
    addressBook.filterBlock = ^BOOL(APContact *contact)
    {
        return
        (contact.phones.count > 0 || contact.emails.count > 0)
        && ( self.filterText.length == 0
            || [contact.compositeName.lowercaseString containsString:self.filterText.lowercaseString]
        );
    };
    [self refreshContactList];
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
                     for(NSString *email in contact.emails) {
                         NSString *key = [NSString stringWithFormat:@"%@,%@", contact.compositeName, email];
                         if([uniqueSet containsObject:key]) {
                             continue;
                         } else {
                             [uniqueSet addObject:key];
                             PeppermintContact *peppermintContact = [PeppermintContact new];
                             peppermintContact.communicationChannel = CommunicationChannelEmail;
                             peppermintContact.communicationChannelAddress = email;
                             peppermintContact.nameSurname = contact.compositeName;
                             peppermintContact.avatarImage = contact.thumbnail;
                             [peppermintContactsArray addObject:peppermintContact];
                         }
                     }
                     for(NSString *phone in contact.phones) {
                         NSString *key = [NSString stringWithFormat:@"%@,%@", contact.compositeName, phone];
                         if([uniqueSet containsObject:key]) {
                             continue;
                         } else {
                             [uniqueSet addObject:key];
                         }
                         PeppermintContact *peppermintContact = [PeppermintContact new];
                         peppermintContact.communicationChannel = CommunicationChannelSMS;
                         peppermintContact.communicationChannelAddress = phone;
                         peppermintContact.nameSurname = contact.compositeName;
                         peppermintContact.avatarImage = contact.thumbnail;
                         [peppermintContactsArray addObject:peppermintContact];
                     }
                 }
                 self.contactList = peppermintContactsArray;
                 NSArray *sortedList = [self.contactList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                     NSString *first = [(PeppermintContact*)a nameSurname];
                     NSString *second = [(PeppermintContact*)b nameSurname];
                     return [first.lowercaseString compare:second.lowercaseString];
                 }];
                 self.contactList = [NSMutableArray arrayWithArray:sortedList];
                 
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

@end
