//
//  ContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsModel.h"

@implementation ContactsModel {
    volatile NSUInteger loadContactsTriggerCount;
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
        [addressBook loadContacts:^(NSArray *contacts, NSError *error)
         {
             if(error) {
                 [self.delegate operationFailure:error];
             } else {
                 NSMutableArray *peppermintContactsArray = [NSMutableArray new];
                 for(APContact *contact in contacts) {
                     for(NSString *email in contact.emails) {
                         PeppermintContact *peppermintContact = [PeppermintContact new];
                         peppermintContact.communicationChannel = CommunicationChannelEmail;
                         peppermintContact.communicationChannelAddress = email;
                         peppermintContact.nameSurname = contact.compositeName;
                         peppermintContact.avatarImage = contact.thumbnail;
                         [peppermintContactsArray addObject:peppermintContact];
                     }
                     for(NSString *phone in contact.phones) {
                         PeppermintContact *peppermintContact = [PeppermintContact new];
                         peppermintContact.communicationChannel = CommunicationChannelSMS;
                         peppermintContact.communicationChannelAddress = phone;
                         peppermintContact.nameSurname = contact.compositeName;
                         peppermintContact.avatarImage = contact.thumbnail;
                         [peppermintContactsArray addObject:peppermintContact];
                     }
                 }
                 self.contactList = peppermintContactsArray;
                 [self.delegate contactListRefreshed];
             }
             
             if(--loadContactsTriggerCount > 0) {
                 NSLog(@"Load contacts method is recalled %d times during the previous query", loadContactsTriggerCount);
                 loadContactsTriggerCount = 0;
                 [self refreshContactList];
             }
         }];
     }
}

@end
