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
-(NSString*) mailBodyHTMLForUrlPath:(NSString*)urlPath extension:(NSString*)extension signature:(NSString*) signature;
@end
