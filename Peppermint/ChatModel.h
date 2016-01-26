//
//  ChatModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "Repository.h"
@class PeppermintContact;

@protocol ChatModelDelegate <BaseModelDelegate>
@optional
-(void) chatsArrayIsUpdated;
-(void) chatEntriesArrayIsUpdated;
-(void) chatHistoryCreatedWithSuccess;
@end

@interface ChatModel : BaseModel
@property (weak, nonatomic) id<ChatModelDelegate> delegate;
@property (strong, atomic, readonly) NSArray<Chat*> *chatArray;
@property (weak, nonatomic) Chat *selectedChat;
@property (strong, atomic, readonly) NSArray<ChatEntry*> *chatEntriesArray;

-(void) refreshChatArray ;
-(void) refreshChatEntries;
- (void) createChatHistoryFor:(PeppermintContact*) peppermintContact withAudioData:(NSData*) audioData transcription:(NSString*) transcription duration:(NSTimeInterval)duration isSentByMe:(BOOL)isSentByMe;

@end
