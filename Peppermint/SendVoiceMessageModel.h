//
//  SendVoiceMessageModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintContact.h"
#import "RecentContactsModel.h"
#import "PeppermintMessageSender.h"
#import "AWSModel.h"

#define TYPE_TEXT   @"text/plain"
#define TYPE_M4A    @"audio/mp4"
#define TYPE_AAC    @"audio/aac"

typedef enum : NSUInteger {
    SendingStatusError = 0,
    SendingStatusCancelled = 1,
    SendingStatusIniting = 2,
    SendingStatusInited = 3,
    SendingStatusStarting = 4,
    SendingStatusCached = 5,
    SendingStatusUploading = 6,
    SendingStatusSending = 7,
    SendingStatusSent = 8,
} SendingStatus;

@protocol SendVoiceMessageDelegate <BaseModelDelegate>
@required
-(void) messageStatusIsUpdated:(SendingStatus) sendingStatus withCancelOption:(BOOL) cancelable;
-(void) newRecentContactisSaved;
@end

@interface SendVoiceMessageModel : BaseModel <RecentContactsModelDelegate, AWSModelDelegate> {
    RecentContactsModel *recentContactsModel;
    AWSModel *awsModel;
}

@property (strong, nonatomic) PeppermintMessageSender *peppermintMessageSender;
@property (strong, nonatomic) PeppermintContact *selectedPeppermintContact;
@property (weak, nonatomic) id<SendVoiceMessageDelegate> delegate;
@property (nonatomic) SendingStatus sendingStatus;

-(void) sendVoiceMessageWithData:(NSData*) data withExtension:(NSString*) extension;
-(NSString*) typeForExtension:(NSString*) extension;
-(BOOL) isServiceAvailable;
-(BOOL) needsAuth;
-(void) messagePrepareIsStarting;
-(void) cancelSending;
-(BOOL) isCancelled;
-(NSString*) fastReplyUrlForSender;
-(BOOL) isConnectionActive;
+(SendVoiceMessageModel*) activeSendVoiceMessageModel;

@end