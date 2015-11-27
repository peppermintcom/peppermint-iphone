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

@interface PeppermintContact : NSObject
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString* nameSurname;
@property (strong, nonatomic) NSString* communicationChannelAddress;
@property (nonatomic) CommunicationChannel communicationChannel;

- (void)addToCoreSpotlightSearch;
- (BOOL) equals:(PeppermintContact*)peppermintContact;

@end
