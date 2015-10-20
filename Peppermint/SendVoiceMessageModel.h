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

@protocol SendVoiceMessageDelegate <BaseModelDelegate>
@required
-(void) messageIsSending;
-(void) messageSentWithSuccess;
@end

@interface SendVoiceMessageModel : BaseModel <RecentContactsModelDelegate>
@property (strong, nonatomic) PeppermintMessageSender *peppermintMessageSender;
@property (strong, nonatomic) PeppermintContact *selectedPeppermintContact;
@property (weak, nonatomic) id<SendVoiceMessageDelegate> delegate;

-(void) sendVoiceMessageWithData:(NSData*) data;

@end