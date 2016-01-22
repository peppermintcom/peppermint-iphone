//
//  ChatEntriesModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatModel.h"

@protocol ChatEntriesModelDelegate <BaseModelDelegate>
@optional
-(void) chatEntriesArrayIsUpdated;
@end

@interface ChatEntriesModel : BaseModel
@property (weak, nonatomic) id<ChatEntriesModelDelegate> delegate;
@property (strong, nonatomic) Chat *chat;
@property (strong, nonatomic, readonly) NSArray<Chat*> *chatEntriesArray;

-(id) initWithChat:(Chat*) chat;

#warning "uncomment line or delete it ;)"
//- (void) refresh;
@end
