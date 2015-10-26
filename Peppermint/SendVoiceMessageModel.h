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

@protocol SendVoiceMessageDelegate <BaseModelDelegate>
@required
-(void) messageIsSendingWithCancelOption:(BOOL) cancelable;
-(void) messageSentWithSuccess;
-(void) messageIsCancelledByTheUserOutOfApp;
@end

@interface SendVoiceMessageModel : BaseModel <RecentContactsModelDelegate, AWSModelDelegate> {
    AWSModel *awsModel;
}

@property (strong, nonatomic) PeppermintMessageSender *peppermintMessageSender;
@property (strong, nonatomic) PeppermintContact *selectedPeppermintContact;
@property (weak, nonatomic) id<SendVoiceMessageDelegate> delegate;
@property (nonatomic) BOOL isCancelled;

-(void) sendVoiceMessageWithData:(NSData*) data withExtension:(NSString*) extension;
-(NSString*) typeForExtension:(NSString*) extension;
-(BOOL) isServiceAvailable;

@end