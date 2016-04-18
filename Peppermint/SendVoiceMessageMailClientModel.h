//
//  SendVoiceMessageMailClientModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageEmailModel.h"
#import "SendVoiceMessageModelAddition.h"

@interface SendVoiceMessageMailClientModel : SendVoiceMessageEmailModel
@property (strong, nonatomic, readonly) NSString *publicFileUrl;
@property (strong, nonatomic, readonly) NSString *canonicalUrl;

@end
