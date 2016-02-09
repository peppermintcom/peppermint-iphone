//
//  ChatModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatModel.h"
#import "ContactsModel.h"

@implementation ChatModel

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
    _chatEntriesArray = [NSArray new];
    self.selectedChat = nil;
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        _chatArray = [repository getResultsFromEntity:[Chat class] predicateOrNil:nil ascSortStringOrNil:nil descSortStringOrNil:nil];
        //[NSArray arrayWithObjects:@"lastMessageDate", nil]

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
            
            for(int j=0; j< messageCount; j++) {
                ChatEntry *chatEntry = (ChatEntry*)[repository createEntity:[ChatEntry class]];
                chatEntry.audio = [NSData new];
                chatEntry.dateCreated = [NSDate dateWithTimeIntervalSinceNow: - rand() % (60*60*24*30*12)];
                chatEntry.isSeen = @NO;
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

-(void) resetChatEntries {
    _chatEntriesArray = [NSArray new];
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

- (void) createChatHistoryFor:(PeppermintContact*) peppermintContact withAudioData:(NSData*) audioData audioUrl:(NSString*)audioUrl transcription:(NSString*) transcription duration:(NSTimeInterval)duration isSentByMe:(BOOL)isSentByMe createDate:(NSDate*)createDate {
    
    weakself_create();
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
        }
        
        if(matchedChat) {
            ChatEntry *chatEntry = (ChatEntry*)[repository createEntity:[ChatEntry class]];
            chatEntry.audio = audioData;
            chatEntry.audioUrl = audioUrl;
            chatEntry.transcription = transcription;
            chatEntry.chat = matchedChat;
            chatEntry.isSentByMe = [NSNumber numberWithBool:isSentByMe];
            chatEntry.dateCreated = createDate;
            chatEntry.isSeen = [NSNumber numberWithBool:isSentByMe];
            chatEntry.duration = [NSNumber numberWithDouble:duration];
            
            NSError *error = [repository endTransaction];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(error) {
                    [weakSelf.delegate operationFailure:error];
                } else {
                    [weakSelf.delegate chatHistoryCreatedWithSuccess];
                }
            });
            
        }
    });
}

#pragma mark - Mark ChatEn

+(void) markChatEntryListened:(ChatEntry *) chatEntry {
    if(!chatEntry.isSentByMe.boolValue) {
        dispatch_async(LOW_PRIORITY_QUEUE, ^{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.audioUrl  ==[c] %@", chatEntry.audioUrl];
            
            Repository *repository = [Repository beginTransaction];
            NSArray *matchedChatEntries = [repository getResultsFromEntity:[chatEntry class] predicateOrNil:predicate];
            
            if(matchedChatEntries.count > 0) {
                ChatEntry *chatEntryInDb = matchedChatEntries.firstObject;
                chatEntryInDb.isSeen = @YES;
                chatEntryInDb.audio = chatEntry.audio;
                chatEntryInDb.duration = chatEntry.duration;
                
                NSError *error = [repository endTransaction];
                if(error) {
                    NSLog(@"Could not mark message as listened");
                }
            } else {
                NSLog(@"Could not find matching chatEntry with url:%@", chatEntry.audioUrl);
            }
        });
        
    } else {
        NSLog(@"Can not mark self sent audio as listened");
    }
}

#pragma mark - Chat Helper Functions

+(NSUInteger) unreadMessageCountOfChat:(Chat*) chat {
    NSPredicate *unreadPredicate = [NSPredicate predicateWithFormat:@"self.isSeen = %@",@NO];
    return [chat.chatEntries filteredSetUsingPredicate:unreadPredicate].count;
}

+(NSDate*) lastMessageDateOfChat:(Chat*) chat {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self.dateCreated" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject: descriptor];
    NSArray *orderedList = [chat.chatEntries sortedArrayUsingDescriptors:descriptors];
    return ((ChatEntry*)orderedList.firstObject).dateCreated;
}

@end
