//
//  ContactsModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintContact.h"

#if !(TARGET_OS_WATCH)
#import "APContact.h"
#import "APAddressBook.h"
@import AddressBook;
#endif


@protocol ContactsModelDelegate <BaseModelDelegate>

-(void) contactsAccessRightsAreNotSupplied;
-(void) contactListRefreshed;

@end

@interface ContactsModel : BaseModel
#if !(TARGET_OS_WATCH)
{
    APAddressBook *addressBook;
}

@property (weak, nonatomic) id<ContactsModelDelegate> delegate;
@property (strong, atomic) NSMutableArray *contactList;
@property (strong, nonatomic) NSString *filterText;

+ (instancetype) sharedInstance;

-(void) setup;
-(void) refreshContactList;

-(NSArray*) emailContactList;
-(NSArray*) smsContactList;
-(PeppermintContact*) matchingPeppermintContactForEmail:(NSString*) email nameSurname:(NSString*) nameSurname;

#endif
#pragma mark - NSPredicate

+(NSPredicate*) contactPredicateWithNameSurname:(NSString*) nameSurname;
+(NSPredicate*) contactPredicateWithCommunicationChannel:(CommunicationChannel) communicationChannel;
+(NSPredicate*) contactPredicateWithCommunicationChannelAddress:(NSString *)communicationChannelAddress;

+(NSPredicate*) contactPredicateWithNameSurname:(NSString*) nameSurname communicationChannel:(CommunicationChannel)communicationChannel;
+(NSPredicate*) contactPredicateWithNameSurnameMatchExact:(NSString*) nameSurname communicationChannel:(CommunicationChannel)communicationChannel;
+(NSPredicate*) contactPredicateWithCommunicationChannelAddress:(NSString*)communicationChannelAddress communicationChannel:(CommunicationChannel)communicationChannel;
+(NSPredicate*) contactPredicateWithNameSurname:(NSString*) nameSurname communicationChannelAddress:(NSString*)communicationChannelAddress communicationChannel:(CommunicationChannel)communicationChannel;

@end
