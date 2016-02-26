//
//  ChatEntryModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntryModel.h"
#import "Repository.h"
#import "PeppermintChatEntry.h"
#import "PeppermintContact.h"
#import "RecentContactsModel.h"

#import "ContactsModel.h"

@implementation ChatEntryModel

-(id) init {
    self = [super init];
    if(self) {
        self.chatEntriesArray = [NSArray new];
    }
    return self;
}

-(void) refreshChatEntriesForContactEmail:(NSString*) contactEmail {
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        NSPredicate *chatPredicate = [NSPredicate predicateWithFormat:@"self.contactEmail == %@", contactEmail];
        
        Repository *repository = [Repository beginTransaction];
        NSArray *chatEntryArray = [repository getResultsFromEntity:[ChatEntry class]
                                                    predicateOrNil:chatPredicate
                                                ascSortStringOrNil:[NSArray arrayWithObjects:@"dateCreated", nil]
                                               descSortStringOrNil:nil];
        
        NSMutableArray *peppermintChatEntryArray = [NSMutableArray new];
        for(ChatEntry* chatEntry in chatEntryArray) {
            PeppermintChatEntry *peppermintChatEntry = [self peppermintChatEntryWith:chatEntry];
            [peppermintChatEntryArray addObject:peppermintChatEntry];
        }
        self.chatEntriesArray = peppermintChatEntryArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(chatEntriesArrayIsUpdated)]) {
                [self.delegate chatEntriesArrayIsUpdated];
            }
        });
    });
}

-(PeppermintChatEntry*) peppermintChatEntryWith:(ChatEntry*)chatEntry {
    PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
    peppermintChatEntry.audio = chatEntry.audio;
    peppermintChatEntry.audioUrl = chatEntry.audioUrl;
    peppermintChatEntry.dateCreated = chatEntry.dateCreated;
    peppermintChatEntry.contactEmail = chatEntry.contactEmail;
    peppermintChatEntry.duration = chatEntry.duration.integerValue;
    peppermintChatEntry.isSeen = chatEntry.isSeen.boolValue;
    peppermintChatEntry.isSentByMe = chatEntry.isSentByMe.boolValue;
    return peppermintChatEntry;
}

-(void) update:(PeppermintChatEntry *) peppermintChatEntry {
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.audioUrl  ==[c] %@", peppermintChatEntry.audioUrl];
        Repository *repository = [Repository beginTransaction];
        NSArray *matchedChatEntries = [repository getResultsFromEntity:[ChatEntry class] predicateOrNil:predicate];
        
        if(matchedChatEntries.count > 0) {
            ChatEntry *chatEntryInDb = matchedChatEntries.firstObject;
            chatEntryInDb.isSeen = [NSNumber numberWithBool:peppermintChatEntry.isSeen];
            chatEntryInDb.duration = [NSNumber numberWithInteger:peppermintChatEntry.duration];
            chatEntryInDb.audio = peppermintChatEntry.audio;
            
            NSError *error = [repository endTransaction];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(error) {
                    [weakSelf.delegate operationFailure:error];
                } else {
                    [weakSelf.delegate peppermintChatEntrySavedWithSuccess:peppermintChatEntry];
                }
            });
        } else {
            NSLog(@"Could not find matching chatEntry with url:%@", peppermintChatEntry.audioUrl);
        }
    });
}

#pragma mark - AddChatHistory

-(void) createChatHistory:(PeppermintChatEntry*)peppermintChatEntry forPeppermintContact:(PeppermintContact*)peppermintContact {
    NSAssert(peppermintContact.nameSurname && peppermintContact.communicationChannelAddress, @"PeppermintContact must be valid to cache!");
    weakself_create();
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        Repository *repository = [Repository beginTransaction];
        ChatEntry *chatEntry = (ChatEntry*)[repository createEntity:[ChatEntry class]];
        chatEntry.contactEmail = peppermintContact.communicationChannelAddress;
        chatEntry.audio = peppermintChatEntry.audio;
        chatEntry.audioUrl = peppermintChatEntry.audioUrl;
        chatEntry.transcription = @"...Transcription should be added...";
        chatEntry.isSentByMe = [NSNumber numberWithBool:peppermintChatEntry.isSentByMe];
        chatEntry.dateCreated = peppermintChatEntry.dateCreated;
        chatEntry.isSeen = [NSNumber numberWithBool:peppermintChatEntry.isSentByMe];
        chatEntry.duration = [NSNumber numberWithDouble:peppermintChatEntry.duration];
        
        NSError *error = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error) {
                [weakSelf.delegate operationFailure:error];
            } else {
                [weakSelf.delegate chatHistoryCreatedWithSuccess];
            }
        });
    });
}

@end
