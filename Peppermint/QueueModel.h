//
//  QueueModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 06/06/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface QueueModel : BaseModel

+ (instancetype) sharedInstance;
-(dispatch_queue_t) transcriptionQueue;
@end
