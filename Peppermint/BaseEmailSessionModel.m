//
//  BaseEmailSessionModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseEmailSessionModel.h"
#import "UidManager.h"
#import "ConnectionModel.h"
#import "PeppermintMessageSender.h"

#define NUMBER_OF_MESSAGES_TO_SYNC      200
#define FIRST_SYNC                      @"First_Sync"

@implementation BaseEmailSessionModel

-(id) init {
    self = [super init];
    if(self) {
        canIdle = NO;
        _session = nil;
        _folderSent = @"";
        _folderInbox = @"";
    }
    return self;
}

-(void) setLoggerActive:(BOOL) active  {
    MCOConnectionLogger logger = nil;
#ifdef DEBUG
    logger = ^(void * connectionID, MCOConnectionLogType type, NSData * data){
        NSLog(@"MCOIMAPSession: [%li] %@", (long)type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    };
#endif
    [self.session setConnectionLogger:active ? logger : nil];
}

#pragma mark - Init Session

-(MCOIMAPSession*) session {
    @throw override_error;
}

-(void) initSession {
    @throw override_error;
}

#pragma mark - Stop Session

-(void) stopSession {
    [self.session cancelAllOperations];
    MCOIMAPOperation * op = [self.session disconnectOperation];
    [op start:^(NSError * error) {
        if(error) {
            [self.delegate operationFailure:error];
        } else {
            _session = nil;
            NSLog(@"%@ session is closed.", self);
        }
    }];
}

#pragma mark - Available Folder List

-(void) logAvailableFolders {
    weakself_create();
    [[self.session fetchAllFoldersOperation] start:^(NSError *error, NSArray *folderNames) {
        if(error) {
            [weakSelf.delegate operationFailure:error];
        } else {
            for(NSString *folder in folderNames) {
                NSLog(@"Folder: %@", folder);
            }
            NSLog(@"--END--");
        }
    }];
}

#pragma mark - Start To Listen Inbox

-(void) startToListenInbox {
    weakself_create();
    MCOIMAPCapabilityOperation * capabilityOperation = [self.session capabilityOperation];
    [capabilityOperation start:^(NSError * error, MCOIndexSet * capabilities) {
        if ([capabilities containsIndex:MCOIMAPCapabilityIdle]) {
            canIdle = YES;
            [weakSelf startListeningFolder:self.folderSent];
        } else {
            #warning "Implement Polling"
            NSLog(@"Session %@ does not support idle. Will/Should do polling.", self.session.username);
        }
    }];
}

#pragma mark - Idle Process

-(void) startListeningFolder:(NSString*) folder {
    NSNumber *firstSyncCompleted = [[UidManager sharedInstance] getUidForUsername:FIRST_SYNC folder:FIRST_SYNC];
    if(firstSyncCompleted.boolValue) {
        [self checkFolderForUpdates:folder];
    } else {
        [self downloadLastMessagesInFolder:folder];
    }
}

-(void) downloadLastMessagesInFolder:(NSString*) folderToDownload {
    MCOIMAPFolderInfoOperation *folderInfo = [self.session folderInfoOperation:folderToDownload];
    weakself_create();
    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
        strongSelf_create();
        if(strongSelf) {
            int numberOfMessages = NUMBER_OF_MESSAGES_TO_SYNC;
            numberOfMessages -= 1;
            MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake([info messageCount] - numberOfMessages, numberOfMessages)];
            MCOIMAPFetchMessagesOperation *fetchOperation = [self.session fetchMessagesByNumberOperationWithFolder:folderToDownload
                                                                                                       requestKind:[self kindToFetch]
                                                                                                           numbers:numbers];
            weakself_create();
            __block NSString *processingFolder = folderToDownload;
            [fetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
                if(error) {
                    [weakSelf.delegate operationFailure:error];
                } else {
                    for (MCOIMAPMessage * message in messages) {
                        [weakSelf processMessage:message inFolder:folderToDownload];
                    }

                    if([processingFolder isEqualToString:weakSelf.folderSent]) {
                        [weakSelf downloadLastMessagesInFolder:weakSelf.folderInbox];
                    } else if ([processingFolder isEqualToString:weakSelf.folderInbox]) {
                        [[UidManager sharedInstance] save:@1 forUsername:FIRST_SYNC folder:FIRST_SYNC];
                        [weakSelf startListeningFolder:weakSelf.folderInbox];
                    }
                }
            }];
        }
    }];
}

-(void) idleForInbox {
    NSString *inboxFolder = self.folderInbox;
    MCOIMAPIdleOperation * idleOperation = [self.session idleOperationWithFolder:inboxFolder lastKnownUID:0];
    weakself_create();
    NSLog(@"Starting idling for folder:%@", inboxFolder);
    [idleOperation start:^(NSError * error) {
        if (error) {
            if([[ConnectionModel sharedInstance] isInternetReachable]) {
                [weakSelf startListeningFolder:self.folderSent];
            } else {
                NSLog(@"Idle had error. No connection. Not restarting..");
                [weakSelf.delegate operationFailure:error];
            }
        } else {
            //There is an update, refresh emails.
            NSLog(@"Idling got message response...");
            [weakSelf startListeningFolder:self.folderSent];
        }
    }];
}

-(MCOIMAPMessagesRequestKind) kindToFetch {
    MCOIMAPMessagesRequestKind kind =
    MCOIMAPMessagesRequestKindUid
    | MCOIMAPMessagesRequestKindFlags
    | MCOIMAPMessagesRequestKindHeaders;
    return  kind;
}

-(void) checkFolderForUpdates:(NSString*)folder {
    weakself_create();
    NSNumber *lastUid = [[UidManager sharedInstance] getUidForUsername:self.session.username folder:folder];
    MCORange range = MCORangeMake(lastUid.integerValue - 10, NUMBER_OF_MESSAGES_TO_SYNC);
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:range];
    NSLog(@"checkFolderForUpdates:%@ -> lastUid:%@, uids to Query:%@", folder, lastUid, uids);
    
    MCOIMAPFetchMessagesOperation *fetchMessagesOperation = [self.session fetchMessagesOperationWithFolder:folder
                                                                       requestKind:[self kindToFetch]
                                                                              uids:uids];
    [fetchMessagesOperation start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
        if(error) {
            [weakSelf.delegate operationFailure:error];
        } else {
            for(MCOIMAPMessage *message in messages) {
                [weakSelf processMessage:message inFolder:folder];
            }
            
            if([folder isEqualToString:weakSelf.folderSent]) {
                [weakSelf checkFolderForUpdates:weakSelf.folderInbox];
            } else if ([folder isEqualToString:weakSelf.folderInbox]) {
                [weakSelf idleForInbox];
            }
        }
    }];
}

-(void) processMessage:(MCOIMAPMessage*)imapMessage inFolder:(NSString*) folder {
    NSLog(@"Processing %@ - uid:%d", folder, imapMessage.uid);
    MCOIMAPFetchContentOperation *fetchContentOperation = [self.session fetchMessageOperationWithFolder:folder uid:imapMessage.uid];
    weakself_create();
    [fetchContentOperation start:^(NSError *error, NSData *data) {
        MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
        NSString *rawMessage = [messageParser plainTextBodyRenderingAndStripWhitespace:NO];
        NSString *processedMessage = [self trimEmailQuoteFromMessage:rawMessage];
        
        
        PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
        peppermintChatEntry.audio = nil;
        peppermintChatEntry.audioUrl = nil;
        peppermintChatEntry.duration = 0;
        peppermintChatEntry.messageId = [NSNumber numberWithInt:imapMessage.uid].stringValue;
        peppermintChatEntry.subject = messageParser.header.partialExtractedSubject;
        peppermintChatEntry.mailContent = processedMessage;
        
        peppermintChatEntry.dateCreated = imapMessage.header.receivedDate;
        peppermintChatEntry.isRepliedAnswered = (imapMessage.flags & MCOMessageFlagAnswered);
        peppermintChatEntry.isStarredFlagged = (imapMessage.flags & MCOMessageFlagFlagged);
        peppermintChatEntry.isForwarded = (imapMessage.flags & MCOMessageFlagForwarded);
        
        peppermintChatEntry.isSentByMe = [folder isEqualToString:self.folderSent];
        if(peppermintChatEntry.isSentByMe) {
            MCOAddress *toAddress = messageParser.header.to.firstObject;
            if(!toAddress) {
                NSLog(@"'To' address can not be empty in an email message! Please check the logic here.");
            } else {
                peppermintChatEntry.contactEmail = toAddress.mailbox;
                peppermintChatEntry.contactNameSurname = toAddress.displayName;
                peppermintChatEntry.isSeen = YES;
            }
        } else {
            peppermintChatEntry.contactEmail = messageParser.header.from.mailbox;
            peppermintChatEntry.contactNameSurname = messageParser.header.from.displayName;
            peppermintChatEntry.isSeen = (imapMessage.flags & MCOMessageFlagSeen);
        }
        
        BOOL isUserStillLoggedIn = [[PeppermintMessageSender sharedInstance] isUserStillLoggedIn];
        if(!isUserStillLoggedIn) {
            NSLog(@"User logged out while fetching email body. Received body is not processed.");
        } else if(peppermintChatEntry.contactEmail.length > 0
           && peppermintChatEntry.subject.length > 0
           && peppermintChatEntry.mailContent.length > 0) {
            [self.delegate receivedMessage:peppermintChatEntry];
            [[UidManager sharedInstance] save:[NSNumber numberWithInt:imapMessage.uid]
                                  forUsername:weakSelf.session.username
                                       folder:folder];
        } else {
            NSLog(@"Can't save email\nContact address:%@\nSubject:%@\nContent:%@\nAll fields must be set to save!\n",
                  peppermintChatEntry.contactEmail,
                  peppermintChatEntry.subject,
                  peppermintChatEntry.mailContent);
        }

        /*
#ifdef DEBUG
//--INVESTIGATION--
        BOOL trimExpected = (message.header.references.count > 0
                             || message.header.inReplyTo.count > 0
                             || message.header.allExtraHeadersNames.count
                             || ![message.header.subject isEqualToString:message.header.extractedSubject]);
        
        if(trimExpected && [rawMessage isEqualToString:processedMessage]) {
            NSLog(@"Maybe to improve trim function?\n---\n\n%@\n", processedMessage);
            for( MCOIMAPPart *imapPart in message.requiredPartsForRendering) {
                NSLog(@"3.Attachment:%@ mime:%@", imapPart.partID, imapPart.mimeType);
                if([imapPart.mimeType isEqualToString:@"text/PLAIN"]) {
                    NSLog(@"Needs text/PLAIN to be rendered!");
                    NSLog(@"CONTACT:%@\nMAIL:%@", newEmailMessageReceived.contactEmail, processedMessage);
                }
            }
            NSLog(@"Please review trimEmailQuoteFromMessage: function. Shall it be improved?");
        }
#endif
        */
    }];
}

/*
 #pragma mark - Session Examples!
 
 - (MCOIMAPSession*)IMAPGoogleSession {
 MCOIMAPSession* IMAPSession = [MCOIMAPSession new];
 IMAPSession.hostname = @"imap.gmail.com";
 IMAPSession.port = 993;
 IMAPSession.username = @"okankurtulus@gmail.com";
 IMAPSession.password = @"XXX";
 IMAPSession.connectionType = MCOConnectionTypeTLS;
 IMAPSession.checkCertificateEnabled = NO;
 [self setLoggerForSession:IMAPSession];
 return IMAPSession;
 }
 
 - (MCOIMAPSession*)IMAPYahooSession {
 MCOIMAPSession* IMAPSession = [MCOIMAPSession new];
 IMAPSession.hostname = @"imap.mail.yahoo.com";
 IMAPSession.port = 993;
 IMAPSession.username = @"okankurtulus@yahoo.com";
 IMAPSession.password = @"XXX";
 IMAPSession.connectionType = MCOConnectionTypeTLS;
 [self setLoggerForSession:IMAPSession];
 return IMAPSession;
 }

*/


-(NSString*) trimEmailQuoteFromMessage:(NSString*) messageText {
    NSArray *textToSplitArray = [NSArray arrayWithObjects:
                                 @"---------- Forwarded message ----------",
                                 @"Begin forwarded message",
                                 @"--",
                                 @"> ",
                                 @"On Monday,",     //On Monday, March...
                                 @"On Tuesday,",    //On Tuesday, March...
                                 @"On Wednesday,",  //On Wednesday, March...
                                 @"On Thursday,",   //On Thursday, March...
                                 @"On Friday,",     //On Friday, March...
                                 @"On Saturday,",   //On Saturday, March...
                                 @"On Sunday,",     //On Sunday, March...
                                 @"On Mon,",     //On Monday, March...
                                 @"On Tue,",    //On Tuesday, March...
                                 @"On Wed,",  //On Wednesday, March...
                                 @"On Thu,",   //On Thursday, March...
                                 @"On Fri,",     //On Friday, March...
                                 @"On Sat,",   //On Saturday, March...
                                 @"On Sun,",     //On Sunday, March...
                                 @"On 1",
                                 @"On 2",
                                 @"On 3",
                                 @"On 4",
                                 @"On 5",
                                 @"On 6",
                                 @"On 7",
                                 @"On 8",
                                 @"On 9",
                                 @"On 0",
                                 @"From:",
                                 @"To:",
                                 nil];
    
    for(NSString *textToSplit in textToSplitArray) {
        messageText = [messageText componentsSeparatedByString:textToSplit].firstObject;
    }
    
    messageText = [messageText trimMultipleNewLines];
    messageText = [messageText trimmedText];
    
    return messageText;
}

@end
