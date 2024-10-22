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
@class Contact;

@interface PeppermintContact : NSObject
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString* nameSurname;
@property (assign, nonatomic) CommunicationChannel communicationChannel;

@property (assign, nonatomic) BOOL hasReceivedMessageOverPeppermint;
@property (strong, nonatomic) NSString *uniqueContactId;
@property (strong, nonatomic) NSDate *lastPeppermintContactDate;
@property (strong, nonatomic) NSDate *lastMailClientContactDate;

@property (assign, nonatomic) NSUInteger unreadAudioMessageCount;
@property (assign, nonatomic) BOOL isRestrictedForRecentContact;

- (void)addToCoreSpotlightSearch;
- (BOOL) equals:(PeppermintContact*)peppermintContact;
- (BOOL) isIdenticalForImage:(PeppermintContact*) contactToCompare;

+ (PeppermintContact *)peppermintContactWithData:(NSData *)data;
- (NSData *)archivedRootData;

#pragma mark - CommunicationChannelAddress
-(NSString*) communicationChannelAddress;
-(void) setCommunicationChannelAddress:(NSString*)communicationChannelAddress;

#pragma mark - Explanation
-(NSString*) explanation;
-(void) setExplanation:(NSString*)explanation;

#pragma mark - Init With Contact
-(instancetype) initWithContact:(Contact*) contact;

@end
