//
//  SendVoiceMessageModelAddition.h
//  Peppermint
//
//  Created by Okan Kurtulus on 08/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageModel.h"

@interface SendVoiceMessageModel (SendVoiceMessageModelAddition)
-(void) tryInterAppMessage:(NSString*) publicUrl;
@end
