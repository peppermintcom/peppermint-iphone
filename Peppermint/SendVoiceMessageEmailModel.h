//
//  SendVoiceMessageEmailModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 06/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageModel.h"


@interface SendVoiceMessageEmailModel : SendVoiceMessageModel {
    NSData *_data;
    NSString *_extension;
}

@property (nonatomic) BOOL isMessageProcessCompleted;

-(BOOL) isConnectionActive;
-(void) cacheMessage;
+(void) triggerCachedMessages;

@end
