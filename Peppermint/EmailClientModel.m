//
//  EmailClientModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "EmailClientModel.h"
#import "GmailEmailSessionModel.h"
#import "RecentContactsModel.h"
#import "ContactsModel.h"

#define MAIL_SAVE_BUFFER_LIMIT      50
#define MAIL_SAVE_LATENCY           3

@implementation EmailClientModel {
    NSMutableArray *mailClientMessageBufferArray;
    NSMutableSet *recentContactsBufferSet;
    NSTimer *bufferArrayTimer;
    ChatEntryModel *chatEntryModel;
    RecentContactsModel *recentContactsModel;
}

-(id) init {
    self = [super init];
    if(self) {
        _emailSessionsArray = [NSMutableArray new];
        mailClientMessageBufferArray = [NSMutableArray new];
        recentContactsBufferSet = [NSMutableSet new];
        bufferArrayTimer = nil;
        chatEntryModel = [ChatEntryModel new];
        chatEntryModel.delegate = self;
        recentContactsModel = [RecentContactsModel new];
        recentContactsModel.delegate = nil;
    }
    return self;
}

-(void) stopExistingSessions {
    for(BaseEmailSessionModel *baseEmailSessionModel in self.emailSessionsArray) {
        [baseEmailSessionModel stopSession];
    }
    #warning Check for a possible memory leak if the session has error on stop. Will it be released?
    [self.emailSessionsArray removeAllObjects];
}

-(void) startEmailClients {
    [self stopExistingSessions];
    
    //Start Logged in Gmail Account
    GmailEmailSessionModel *gmailEmailSessionModel = [GmailEmailSessionModel new];
    gmailEmailSessionModel.delegate = self;
    [self.emailSessionsArray addObject:gmailEmailSessionModel];
    [gmailEmailSessionModel initSession];
}

SUBSCRIBE(UserLoggedOut) {
    [self stopExistingSessions];
    [bufferArrayTimer invalidate];
}

#pragma mark - BaseEmailSessionModelDelegate

-(void) receivedMessage:(PeppermintChatEntry*) peppermintChatEntry {
    [bufferArrayTimer invalidate];
    bufferArrayTimer = nil;
    PeppermintContact *peppermintContact = [[ContactsModel sharedInstance]
                                            matchingPeppermintContactForEmail:peppermintChatEntry.contactEmail
                                            nameSurname:peppermintChatEntry.contactNameSurname];
    
    if(chatEntryModel && recentContactsModel) {
        [mailClientMessageBufferArray addObject:peppermintChatEntry];
        peppermintContact.lastMailClientContactDate = peppermintChatEntry.dateCreated;
        [recentContactsBufferSet addOrUpdateObject:peppermintContact];
        
        if(mailClientMessageBufferArray.count >= MAIL_SAVE_BUFFER_LIMIT) {
            [self bufferArrayTimerTriggered];
        } else {
            bufferArrayTimer = [NSTimer scheduledTimerWithTimeInterval:MAIL_SAVE_LATENCY
                                                                target:self
                                                              selector:@selector(bufferArrayTimerTriggered)
                                                              userInfo:nil
                                                               repeats:NO];
        }
    } else {
        NSLog(@"A model was not inited properly. This may cause a message not to be shown properly.");
    }
}

-(void) bufferArrayTimerTriggered {
    [bufferArrayTimer invalidate];
    
    NSArray *recentPeppermintContactsToSave = [recentContactsBufferSet allObjects];
    [recentContactsModel saveMultiple:recentPeppermintContactsToSave];
    
    NSArray *messagesToBeSaved = [NSArray arrayWithArray:mailClientMessageBufferArray];
    NSLog(@"%ld mail messages are triggered to be saved!", (unsigned long)messagesToBeSaved.count);
    [chatEntryModel savePeppermintChatEntryArray:messagesToBeSaved];
    
    recentContactsBufferSet = [NSMutableSet new];
    mailClientMessageBufferArray = [NSMutableArray new];
}

#pragma mark - ChatEntryModelDelegate
-(void) operationFailure:(NSError*) error {
    [self.delegate operationFailure:error];
}

-(void) peppermintChatEntriesArrayIsUpdated {
    [self.delegate peppermintChatEntriesArrayIsUpdated];
}

-(void) peppermintChatEntrySavedWithSuccess:(NSArray*) savedPeppermintChatEnryArray {
    [self.delegate peppermintChatEntrySavedWithSuccess:savedPeppermintChatEnryArray];
}

-(void) lastMessagesAreUpdated:(NSArray<PeppermintContactWithChatEntry*>*) peppermintContactWithChatEntryArray {
    [self.delegate lastMessagesAreUpdated:peppermintContactWithChatEntryArray];
}

@end
