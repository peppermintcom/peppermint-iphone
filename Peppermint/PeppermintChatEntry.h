//
//  PeppermintChatEntry.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Attribute;

typedef enum : NSUInteger {
    PerformedOperationNone,
    PerformedOperationCreated,
    PerformedOperationUpdated,
} PerformedOperation;

@interface PeppermintChatEntry : NSObject <NSCopying>

@property (strong, nonatomic) NSData *audio;
@property (strong, nonatomic) NSString *audioUrl;
@property (strong, nonatomic) NSDate *dateCreated;
@property (strong, nonatomic) NSString *contactEmail;
@property (strong, nonatomic) NSString *contactNameSurname;
@property (assign, nonatomic) NSInteger duration;
@property (assign, nonatomic) BOOL isSeen;
@property (assign, nonatomic) BOOL isSentByMe;
@property (strong, nonatomic) NSString *messageId;
@property (assign, nonatomic) PerformedOperation performedOperation;

+(PeppermintChatEntry*) createFromAttribute:(Attribute*) attribute isIncomingMessage:(BOOL)isIncoming;
@end
