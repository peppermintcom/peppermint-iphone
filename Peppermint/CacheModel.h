//
//  CacheModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 07/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
@class SendVoiceMessageModel;

@interface CacheModel : BaseModel

+ (instancetype) sharedInstance;
-(void) cache:(SendVoiceMessageModel*) sendVoiceMessageModel WithData:(NSData*) data extension:(NSString*) extension duration:(NSTimeInterval)duration;
-(void) triggerCachedMessages;
-(void) cacheOngoingMessages;
@end
