//
//  ContactsModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintContact.h"
@import AddressBook;
#import "APContact.h"
#import "APAddressBook.h"

@protocol ContactsModelDelegate <BaseModelDelegate>
-(void) contactsAccessRightsAreNotSupplied;
-(void) contactListRefreshed;
@end

@interface ContactsModel : BaseModel {
    APAddressBook *addressBook;
}

@property (weak, nonatomic) id<ContactsModelDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *contactList;
@property (strong, nonatomic) NSString *filterText;

+ (instancetype) sharedInstance;

-(void) setup;
-(void) refreshContactList;

-(NSArray*) emailContactList;
-(NSArray*) smsContactList;

@end
