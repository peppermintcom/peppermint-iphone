//
//  SendVoiceMessageEmailModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 06/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageModel.h"
#import "CacheModel.h"

@interface SendVoiceMessageEmailModel : SendVoiceMessageModel

@property (strong, nonatomic) NSString *subject;

-(NSString*) mailBodyHTMLForUrlPath:(NSString*)urlPath extension:(NSString*)extension signature:(NSString*) signature duration:(NSTimeInterval) duration;
@end
