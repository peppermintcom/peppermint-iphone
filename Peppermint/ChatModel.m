//
//  ChatModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatModel.h"
#import "ContactsModel.h"

#define PREDICATE_UNREAD_MESSAGES [NSPredicate predicateWithFormat:@"self.isSeen = %@",@NO]

@implementation ChatModel

+ (instancetype) sharedInstance {
    return SHARED_INSTANCE( [[self alloc] initShared] );
}

-(id) init {
    NSAssert(false, @"This model instance is singleton so should not be inited - %@", self);
    return nil;
}

-(id) initShared {
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
        _chatArray = [repository getResultsFromEntity:[Chat class] predicateOrNil:nil ascSortStringOrNil:nil descSortStringOrNil:
                      [NSArray arrayWithObjects:@"lastMessageDate", nil]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(chatsArrayIsUpdated)]) {
                [self.delegate chatsArrayIsUpdated];
            }
        });
    });
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
    NSAssert(peppermintContact.nameSurname && peppermintContact.communicationChannelAddress, @"PeppermintContact must be valid to cache!");
    
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Chat *matchedChat = nil;
        NSPredicate *addressPredicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:peppermintContact.communicationChannelAddress];
        //NSPredicate *nameSurnamePredicate = [ContactsModel contactPredicateWithNameSurname:peppermintContact.nameSurname];
        //NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects: addressPredicate, nameSurnamePredicate, nil]];
        
        Repository *repository = [Repository beginTransaction];
        NSArray *matchedChatsArray = [repository getResultsFromEntity:[Chat class] predicateOrNil:addressPredicate];
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
            
            if(!matchedChat.lastMessageDate || [createDate laterDate:matchedChat.lastMessageDate]) {
                matchedChat.lastMessageDate = createDate;
            }
            
            NSError *error = [repository endTransaction];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(error) {
                    [weakSelf.delegate operationFailure:error];
                } else {                    
                    if([weakSelf.delegate respondsToSelector:@selector(chatHistoryCreatedWithSuccess)]) {
                        [weakSelf.delegate chatHistoryCreatedWithSuccess];
                    }
                    [weakSelf refreshChatEntries];
                }
            });
            
        }
    });
}

#pragma mark - Mark ChatEntry

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
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[AppDelegate Instance] refreshBadgeNumber];
                    });
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
    return [chat.chatEntries filteredSetUsingPredicate:PREDICATE_UNREAD_MESSAGES].count;
}

+(NSDate*) lastMessageDateOfChat:(Chat*) chat {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self.dateCreated" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject: descriptor];
    NSArray *orderedList = [chat.chatEntries sortedArrayUsingDescriptors:descriptors];
    return ((ChatEntry*)orderedList.firstObject).dateCreated;
}

+(NSUInteger) unreadMessageCountOfAllChats {
    Repository *repository = [Repository beginTransaction];
    NSArray *unreadChatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:PREDICATE_UNREAD_MESSAGES];
    return  unreadChatEntries.count;
}


+(NSSet*) receivedMessagesEmailSet {
    Repository *repository = [Repository beginTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.isSentByMe == %@", @NO];
    NSArray *chatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
    
    NSMutableSet *mutableSet = [NSMutableSet new];
    for(ChatEntry *chatEntry in chatEntries) {
        [mutableSet addObject:chatEntry.chat.communicationChannelAddress];
    }
    return mutableSet;
}

@end
