//
//  PlayingModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

typedef void(^PlayerCompletitionBlock)(void);

@interface PlayingModel : BaseModel
-(BOOL) playBeginRecording:(PlayerCompletitionBlock) playerCompletitionBlock;
@end
