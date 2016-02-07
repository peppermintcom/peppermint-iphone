//
//  ChatModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatModel.h"
#import "ContactsModel.h"

@implementation ChatModel {
    NSDateFormatter *dateFormatter;
}

-(id) init {
    self = [super init];
    if(self) {
        _chatArray = [NSArray new];
        self.selectedChat = nil;
        _chatEntriesArray = [NSArray new];
    }
    return self;
}

#pragma mark - Refresh

-(void) refreshChatArray {
    self.selectedChat = nil;
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        _chatArray = [repository getResultsFromEntity:[Chat class] predicateOrNil:nil ascSortStringOrNil:nil descSortStringOrNil:[NSArray arrayWithObjects:@"lastMessageDate", nil]];

#ifdef DEBUG
        //[self checkAndCreateRandomChats:repository];
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(chatsArrayIsUpdated)]) {
                [self.delegate chatsArrayIsUpdated];
            }
        });
    });
}

-(void) checkAndCreateRandomChats:(Repository*) repository {
    if(_chatArray.count < 3) {
        for(int i=0; i<7; i++) {
            Chat *chat = (Chat*)[repository createEntity:[Chat class]];
            chat.avatarImageData = nil;
            chat.communicationChannel = @0;
            chat.communicationChannelAddress = [NSString stringWithFormat:@"_%@", [[NSString alloc] randomStringWithLength: rand() % 15]];
            chat.nameSurname = [NSString stringWithFormat:@"_%@ %@",
                                [[NSString alloc] randomStringWithLength:rand() % 5],
                                [[NSString alloc] randomStringWithLength:rand() % 7]];
            
            int messageCount = rand() % 9;
            chat.unreadMessageCount = [NSNumber numberWithInt:messageCount];
            chat.lastMessageDate = [NSDate dateWithTimeIntervalSinceNow: - rand() % (60*60*24*30*12)];
            
            for(int j=0; j< messageCount; j++) {
                ChatEntry *chatEntry = (ChatEntry*)[repository createEntity:[ChatEntry class]];
                chatEntry.audio = [NSData new];
                chatEntry.dateCreated = [NSDate dateWithTimeIntervalSinceNow: - rand() % (60*60*24*30*12)];
                chatEntry.dateListened = [NSDate dateWithTimeIntervalSinceNow:0];
                chatEntry.dateViewed = [NSDate dateWithTimeIntervalSinceNow:0];
                chatEntry.isSentByMe = [NSNumber numberWithBool:(j%2 == 0)];
                chatEntry.transcription = [[NSString alloc] randomStringWithLength:rand() % 15];
                chatEntry.chat = chat;
            }
            
        }
        NSLog(@"Created chats for test usage!!!");
        [repository endTransaction];
        repository = [Repository beginTransaction];
    }
}

-(void) refreshChatEntries {
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        NSPredicate *chatPredicate = [NSPredicate predicateWithFormat:@"self.chat.nameSurname = %@ AND self.chat.communicationChannelAddress = %@",
                                      self.selectedChat.nameSurname,
                                      self.selectedChat.communicationChannelAddress];
        _chatEntriesArray = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:chatPredicate ascSortStringOrNil:[NSArray arrayWithObjects:@"dateCreated", nil] descSortStringOrNil:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(chatEntriesArrayIsUpdated)]) {
                [self.delegate chatEntriesArrayIsUpdated];
            }
        });
    });
}

#pragma mark - AddChatHistory

- (void) createChatHistoryFor:(PeppermintContact*) peppermintContact withAudioData:(NSData*) audioData transcription:(NSString*) transcription duration:(NSTimeInterval)duration isSentByMe:(BOOL)isSentByMe {

    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Chat *matchedChat = nil;
        NSPredicate *addressPredicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:peppermintContact.communicationChannelAddress];
        NSPredicate *nameSurnamePredicate = [ContactsModel contactPredicateWithNameSurname:peppermintContact.nameSurname];
        NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:
                                          [NSArray arrayWithObjects: addressPredicate, nameSurnamePredicate, nil]
                                          ];
        
        Repository *repository = [Repository beginTransaction];
        NSArray *matchedChatsArray = [repository getResultsFromEntity:[Chat class] predicateOrNil:predicate];
        if(matchedChatsArray.firstObject) {
            matchedChat = (Chat*) matchedChatsArray.firstObject;
        } else {
            matchedChat = (Chat*)[repository createEntity:[Chat class]];
            matchedChat.avatarImageData = UIImagePNGRepresentation(peppermintContact.avatarImage);
            matchedChat.communicationChannel = [NSNumber numberWithInt:peppermintContact.communicationChannel];
            matchedChat.communicationChannelAddress = peppermintContact.communicationChannelAddress;
            matchedChat.nameSurname = peppermintContact.nameSurname;
            matchedChat.lastMessageDate = [NSDate new];
            matchedChat.unreadMessageCount = @0;
            matchedChat.chatEntries = nil;
        }
        
        if(matchedChat) {
            ChatEntry *chatEntry = (ChatEntry*)[repository createEntity:[ChatEntry class]];
            NSDate *dateNow = [NSDate new];
            chatEntry.audio = audioData;
            chatEntry.transcription = transcription;
            chatEntry.chat = matchedChat;
            chatEntry.isSentByMe = [NSNumber numberWithBool:isSentByMe];
            chatEntry.dateCreated = dateNow;
            chatEntry.dateListened = dateNow;
            chatEntry.dateViewed = dateNow;
            chatEntry.duration = [NSNumber numberWithDouble:duration];
            matchedChat.lastMessageDate = dateNow;
        }
        
        NSError *error = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                [self.delegate operationFailure:error];
            } else {
                [self.delegate chatHistoryCreatedWithSuccess];
            }
        });
    });
}

@end
