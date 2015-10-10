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

@protocol SendVoiceMessageDelegate <BaseModelDelegate>
@required
-(void) messageSentWithSuccess;
@end

@interface SendVoiceMessageModel : BaseModel <RecentContactsModelDelegate>
@property (strong, nonatomic) PeppermintContact *selectedPeppermintContact;
@property (weak, nonatomic) id<SendVoiceMessageDelegate> delegate;

-(void) sendVoiceMessageWithData:(NSData*) data;

@end