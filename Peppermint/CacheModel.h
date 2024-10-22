//
//  CacheModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 07/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "TranscriptionInfo.h"
@class SendVoiceMessageModel;

@interface CacheModel : BaseModel

+ (instancetype) sharedInstance;
-(void) cache:(SendVoiceMessageModel*) sendVoiceMessageModel WithData:(NSData*) data extension:(NSString*) extension duration:(NSTimeInterval)duration transcriptionInfo:(TranscriptionInfo*)transcriptionInfo;
-(void) triggerCachedMessages;
-(void) cacheOngoingMessages;

#pragma mark - Cache On Defaults
-(void) cacheOnDefaults:(SendVoiceMessageModel*) sendVoiceMessageModel;
-(SendVoiceMessageModel*) cachedSendVoiceMessageModelFromDefaults;

@end
