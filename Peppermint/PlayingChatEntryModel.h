//
//  PlayingChatEntryModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/03/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
@class PlayingModel;
@class PeppermintChatEntry;

@interface PlayingChatEntryModel : BaseModel
@property (nonatomic, strong) PlayingModel *cachedPlayingModel;

+ (instancetype) sharedInstance;
-(PlayingModel*) playModelForChatEntry:(PeppermintChatEntry*) peppermintChatEntry;

@end
