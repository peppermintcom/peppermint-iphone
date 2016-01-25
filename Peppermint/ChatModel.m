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
    }
    return self;
}

- (void) dealloc {
}

- (void) refreshChatArray {
    self.selectedChat = nil;
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        _chatArray = [repository getResultsFromEntity:[Chat class]];
#ifdef DEBUG
        #warning "Dont forget to delete here!"
        [self checkAndCreateRandomChats:repository];
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


+(NSURL*) getChatUdidForPeppermintContact:(PeppermintContact*) peppermintContact error:(NSError**) error {
    
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
    
    *error = [repository endTransaction];
    return matchedChat.objectID.URIRepresentation;
}


@end
