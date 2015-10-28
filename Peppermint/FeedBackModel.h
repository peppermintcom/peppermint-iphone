//
//  FeedBackModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@protocol FeedBackModelDelegate <BaseModelDelegate>
-(void) feedBackSentWithSuccess;
@end

@interface FeedBackModel : BaseModel
@property (weak, nonatomic) id<FeedBackModelDelegate> delegate;
-(void) sendFeedBackMail;
@end
