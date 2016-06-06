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

typedef enum : NSUInteger {
    ChatEntryTypeNone       = 0,
    ChatEntryTypeAudio      = 1 << 0,
    ChatEntryTypeEmail      = 1 << 1,
} ChatEntryType;

@interface PeppermintChatEntry : NSObject <NSCopying>

#pragma mark - Base Content
@property (strong, nonatomic) NSDate *dateCreated;
@property (strong, nonatomic) NSString *contactNameSurname;
@property (assign, nonatomic) BOOL isSeen;
@property (assign, nonatomic) BOOL isSentByMe;
@property (strong, nonatomic) NSString *messageId;
@property (assign, nonatomic) PerformedOperation performedOperation;
@property (strong, nonatomic) NSString *transcription;

#pragma mark - Audio Content
@property (strong, nonatomic) NSData *audio;
@property (strong, nonatomic) NSString *audioUrl;
@property (assign, nonatomic) NSInteger duration;

#pragma mark - Email Content
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *mailContent;
@property (assign, nonatomic) BOOL isRepliedAnswered;
@property (assign, nonatomic) BOOL isStarredFlagged;
@property (assign, nonatomic) BOOL isForwarded;

+(PeppermintChatEntry*) createFromAttribute:(Attribute*) attribute isIncomingMessage:(BOOL)isIncoming;
-(void) setContactEmail:(NSString*)email;
-(NSString*) contactEmail;
-(ChatEntryType) type;

@end
