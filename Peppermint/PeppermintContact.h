//
//  PeppermintContact.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CommunicationChannelNone,
    CommunicationChannelEmail,
    CommunicationChannelSMS,
} CommunicationChannel;

@import UIKit;

@interface PeppermintContact : NSObject
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString* nameSurname;
@property (assign, nonatomic) CommunicationChannel communicationChannel;
@property (assign, nonatomic) BOOL hasReceivedMessageOverPeppermint;
@property (strong, nonatomic) NSString *uniqueContactId;
@property (strong, nonatomic) NSDate *lastMessageDate;
@property (assign, nonatomic) NSUInteger unreadMessageCount;


- (void)addToCoreSpotlightSearch;
- (BOOL) equals:(PeppermintContact*)peppermintContact;
- (BOOL) isIdenticalForImage:(PeppermintContact*) contactToCompare;

+ (PeppermintContact *)peppermintContactWithData:(NSData *)data;
- (NSData *)archivedRootData;

#pragma mark - CommunicationChannelAddress
//Added setter&getter instead of -> @property (strong, nonatomic) NSString* communicationChannelAddress;

-(NSString*) communicationChannelAddress;
-(void) setCommunicationChannelAddress:(NSString*)communicationChannelAddress;

@end
