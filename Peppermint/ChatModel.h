//
//  ChatModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "Repository.h"

@protocol ChatModelDelegate <BaseModelDelegate>
@optional
-(void) chatsArrayIsUpdated;
@end

@interface ChatModel : BaseModel
@property (weak, nonatomic) id<ChatModelDelegate> delegate;
@property (strong, nonatomic, readonly) NSArray<Chat*> *chatArray;
@property (weak, nonatomic) Chat *selectedChat;

- (void) refreshChatArray ;

@end
