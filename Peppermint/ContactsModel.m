//
//  ContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsModel.h"

@implementation ContactsModel

-(id) init {
    self = [super init];
    if(self) {
        self.contactList = [NSMutableArray new];
        self.filterText = @"";
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
            [self.delegate accessRightsAreNotSupplied];
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
                [self.delegate accessRightsAreNotSupplied];
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
    }];
}

@end
