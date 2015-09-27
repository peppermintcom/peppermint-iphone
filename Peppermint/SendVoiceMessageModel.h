//
//  SendVoiceMessageModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintContact.h"

@interface SendVoiceMessageModel : BaseModel
@property (strong, nonatomic) PeppermintContact *selectedPeppermintContact;

-(void) sendVoiceMessageatURL:(NSURL*) url;

@end
