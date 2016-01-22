//
//  ChatModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatModel.h"

@interface ChatModel()
@property (strong, nonatomic) Repository *repository;

@end

@implementation ChatModel {
    NSDateFormatter *dateFormatter;
}

-(id) init {
    self = [super init];
    if(self) {
        self.repository = [Repository beginTransaction];
        _chatArray = [NSArray new];
        self.selectedChat = nil;
    }
    return self;
}

- (void) dealloc {
    NSError *error = [self.repository endTransaction];
    if(error) {
        [self.delegate operationFailure:error];
    }
}

- (void) refreshChatArray {
    self.selectedChat = nil;
    _chatArray = [self.repository getResultsFromEntity:[Chat class]];
    [self checkAndCreateRandomChats];
}

#warning "Dont forget to delete here!"
-(void) checkAndCreateRandomChats {
    if(_chatArray.count < 3) {
        
#ifdef DEBUG
        for(int i=0; i<5; i++) {
            Chat *chat = (Chat*)[self.repository createEntity:[Chat class]];
            chat.avatarImageData = nil;
            chat.communicationChannel = @0;
            chat.communicationChannelAddress = [NSString stringWithFormat:@"%@", [[NSString alloc] randomStringWithLength: rand() % 15]];
            chat.nameSurname = [NSString stringWithFormat:@"%@ %@",
                                [[NSString alloc] randomStringWithLength:rand() % 5],
                                [[NSString alloc] randomStringWithLength:rand() % 7]];
            
            int messageCount = rand() % 100;
            chat.unreadMessageCount = [NSNumber numberWithInt:messageCount];
            chat.lastMessageDate = [NSDate dateWithTimeIntervalSinceNow: - rand() % (60*60*24*30*12)];
            
            for(int j=0; j< messageCount; j++) {
                ChatEntry *chatEntry = (ChatEntry*)[self.repository createEntity:[ChatEntry class]];
                chatEntry.audio = [NSData new];
                chatEntry.dateCreated = [NSDate dateWithTimeIntervalSinceNow: - rand() % (60*60*24*30*12)];
                chatEntry.dateListened = [NSDate dateWithTimeIntervalSinceNow:0];
                chatEntry.dateViewed = [NSDate dateWithTimeIntervalSinceNow:0];
                chatEntry.isSentByMe = [NSNumber numberWithBool:((rand()%2)== 0)];
                chatEntry.transcription = [[NSString alloc] randomStringWithLength:rand() % 15];
                chatEntry.chat = chat;
            }
            
        }
        NSLog(@"Created chats!");
        [self.repository endTransaction];
        self.repository = [Repository beginTransaction];
        [self refreshChatArray];
#else
        if([self.delegate respondsToSelector:@selector(chatsArrayIsUpdated)]) {
            [self.delegate chatsArrayIsUpdated];
        }
#endif
    } else {
        if([self.delegate respondsToSelector:@selector(chatsArrayIsUpdated)]) {
            [self.delegate chatsArrayIsUpdated];
        }
    }
}

@end
