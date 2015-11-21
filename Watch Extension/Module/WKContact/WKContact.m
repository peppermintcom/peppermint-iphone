//
//  WKContact.m
//  Peppermint
//
//  Created by Yan Saraev on 11/20/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "WKContact.h"
#import "PeppermintContact.h"

@import Contacts;

@implementation WKContact

+ (void)allContacts:(void (^)(NSArray <PeppermintContact *> * contacts))block {
  
#ifdef DEBUG
  PeppermintContact * ppm_contact = [[PeppermintContact alloc] init];
  ppm_contact.communicationChannelAddress = @"yansaraev@mail.ru";
  ppm_contact.nameSurname = @"Yan Saraev";
  block(@[ppm_contact]);
  return;
#endif

  CNContactStore * store = [[CNContactStore alloc] init];

  [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * error) {
    if (!granted || error) {
       block(@[]);
    }
    
    NSArray * fetchKeys = @[CNContactEmailAddressesKey, CNContactFamilyNameKey, CNContactGivenNameKey];
    CNContactFetchRequest * fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    
    __block NSMutableArray * contacts = [NSMutableArray array];
    
    NSError * err;
    [store enumerateContactsWithFetchRequest:fetchRequest error:&err usingBlock:^(CNContact * contact, BOOL * stop) {
      if (contact.emailAddresses.count > 0) {
        for (CNLabeledValue * labeledValue in contact.emailAddresses) {
          PeppermintContact * ppm_contact = [[PeppermintContact alloc] init];
          ppm_contact.communicationChannelAddress = labeledValue.value;
          ppm_contact.nameSurname = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
          [contacts addObject:ppm_contact];
        }
      }
    }];
    
#ifdef DEBUG
    PeppermintContact * ppm_contact = [[PeppermintContact alloc] init];
    ppm_contact.communicationChannelAddress = @"yansaraev@mail.ru";
    ppm_contact.nameSurname = @"Yan Saraev";
    [contacts addObject:ppm_contact];
#endif
    if (err) {
      NSLog(@"error: %@", err);
    }
    block(contacts);
  }];
}

@end
