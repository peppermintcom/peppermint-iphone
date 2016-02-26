//
//  ChatModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
@class PeppermintContact;

@protocol ChatModelDelegate <BaseModelDelegate>
@optional
-(void) chatsArrayIsUpdated;
@end

@interface ChatModel : BaseModel
@property (weak, nonatomic) id<ChatModelDelegate> delegate;
@property (strong, atomic) NSArray<PeppermintContact*> *chatArray;

-(void) refreshChatArray ;

+(NSPredicate*) unreadMessagesPredicateForEmail:(NSString*) email;
+(NSUInteger) unreadMessageCountOfAllChats;
+(NSSet*) receivedMessagesEmailSet;

@end
