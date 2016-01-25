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
@property (strong, nonatomic, readonly) NSArray<ChatEntry*> *chatEntriesArray;

-(id) initWithChat:(Chat*) chat;
-(void) refreshChatEntries;
-(void) saveSentAudio:(NSData*) audioData transcription:(NSString*)transcription chatUrl:(NSURL*)chatUrl;

@end
