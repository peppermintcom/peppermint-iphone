//
//  BaseEmailSessionModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseEmailSessionModel.h"
#import "UidManager.h"

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
    MCOIMAPOperation * op = [self.session disconnectOperation];
    [op start:^(NSError * error) {
        if(error) {
            [self.delegate operationFailure:error];
        } else {
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
            [weakSelf startListeningFolder:self.folderInbox];
        } else {
            #warning "Implement Polling"
            NSLog(@"Session %@ does not support idle. Will/Should do polling.", self.session.username);
        }
    }];
}

#pragma mark - Idle Process

-(void) startListeningFolder:(NSString*) folder {
    NSNumber *lastUid = [[UidManager sharedInstance] getUidForUsername:self.session.username folder:folder];
    if(lastUid && lastUid.intValue > 0) {
        [self idleForInboxFromUid:lastUid];
    } else {
        [self downloadLastMessagesInFolder:self.folderInbox];
    }
}

-(void) downloadLastMessagesInFolder:(NSString*) folderToDownload {
    MCOIMAPFolderInfoOperation *folderInfo = [self.session folderInfoOperation:folderToDownload];
    weakself_create();
    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
        strongSelf_create();
        if(strongSelf) {
            int numberOfMessages = 100;
            numberOfMessages -= 1;
            MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake([info messageCount] - numberOfMessages, numberOfMessages)];
            MCOIMAPFetchMessagesOperation *fetchOperation = [self.session fetchMessagesByNumberOperationWithFolder:folderToDownload
                                                                                                       requestKind:MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure | MCOIMAPMessagesRequestKindFlags
                                                                                                           numbers:numbers];
            weakself_create();
            __block NSString *processingFolder = folderToDownload;
            [fetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
                if(error) {
                    [weakSelf.delegate operationFailure:error];
                } else {
                    NSUInteger lastUdid = 0;
                    for (MCOIMAPMessage * message in messages) {
                        lastUdid = MAX(lastUdid, message.uid);
                        [weakSelf processMessage:message inFolder:folderToDownload];
                    }
                    [[UidManager sharedInstance] save:[NSNumber numberWithInteger:lastUdid]
                                          forUsername:self.session.username
                                               folder:processingFolder];
                    
                    if(![processingFolder isEqualToString:self.folderSent]) {
                        [self downloadLastMessagesInFolder:self.folderSent];
                    } else {
                        [self startListeningFolder:self.folderInbox];
                    }
                }
            }];
        }
    }];
}

-(void) idleForInboxFromUid:(NSNumber*)uid {
    NSString *inboxFolder = self.folderInbox;
    [[UidManager sharedInstance] save:uid forUsername:self.session.username folder:inboxFolder];
    MCOIMAPIdleOperation * idleOperation = [self.session idleOperationWithFolder:inboxFolder lastKnownUID:abs(uid.intValue)];
    weakself_create();
    [idleOperation start:^(NSError * error) {
        if (error) {
            [weakSelf.delegate operationFailure:error];
            NSLog(@"Restarting idle...");
            [weakSelf idleForInboxFromUid:uid];
        } else {
            [weakSelf readFolder:inboxFolder fromUid:uid];
        }
    }];
}

/*
-(void) checkFolderForUnreadMessages:(NSString*)folder {
    weakself_create();
    MCOIMAPFolderInfoOperation *folderInfoOperation = [self.session folderInfoOperation:folder];
    [folderInfoOperation start:^(NSError *error, MCOIMAPFolderInfo *info) {
        if(error) {
            [weakSelf.delegate operationFailure:error];
        } else {
            [weakSelf readFolder:folder fromUid:[NSNumber numberWithInt:info.uidNext]];
        }
    }];
}*/

-(void) readFolder:(NSString*)folder fromUid:(NSNumber*) uid {
    weakself_create();
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(uid.integerValue-1, UINT64_MAX)];
    MCOIMAPFetchMessagesOperation *fetchMessagesOperation = [self.session fetchMessagesOperationWithFolder:folder
                                                                       requestKind:MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure | MCOIMAPMessagesRequestKindFlags
                                                                              uids:uids];
    [fetchMessagesOperation start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
        if(error) {
            [weakSelf.delegate operationFailure:error];
        } else {
            NSUInteger nextQueryUid = uid.integerValue;
            for(MCOIMAPMessage *message in messages) {
                [weakSelf processMessage:message inFolder:folder];
                nextQueryUid = MAX(nextQueryUid, message.uid);
            }
            [weakSelf idleForInboxFromUid:[NSNumber numberWithInteger:nextQueryUid]];
        }
    }];
}

-(void) processMessage:(MCOIMAPMessage*)message inFolder:(NSString*) folder {
    
    MCOIMAPFetchContentOperation *fetchContentOperation = [self.session fetchMessageOperationWithFolder:folder uid:message.uid];
    weakself_create();
    [fetchContentOperation start:^(NSError *error, NSData *data) {
        MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:data];
        NSString *rawMessage = [messageParser plainTextBodyRenderingAndStripWhitespace:NO];
        NSString *processedMessage = [self trimEmailQuoteFromMessage:rawMessage];
        
        NewEmailMessageReceived *newEmailMessageReceived = [NewEmailMessageReceived new];
        newEmailMessageReceived.sender = weakSelf;
        newEmailMessageReceived.uid = [NSNumber numberWithInt:message.uid];
        newEmailMessageReceived.subject = message.header.subject;
        newEmailMessageReceived.message = processedMessage;
        newEmailMessageReceived.dateReceived = message.header.receivedDate;
        newEmailMessageReceived.isSent = [folder isEqualToString:self.folderSent];
        if(newEmailMessageReceived.isSent) {
            MCOAddress *toAddress = message.header.to.firstObject;
            if(!toAddress) {
                NSLog(@"'To' address can not be empty in an email message! Please check the logic here.");
            } else {
                newEmailMessageReceived.contactEmail = toAddress.mailbox;
                newEmailMessageReceived.contactNameSurname = toAddress.displayName;
                newEmailMessageReceived.isSeen = YES;
            }
        } else {
            newEmailMessageReceived.contactEmail = message.header.from.mailbox;
            newEmailMessageReceived.contactNameSurname = message.header.from.displayName;
            newEmailMessageReceived.isSeen = (message.flags & MCOMessageFlagSeen);
        }
        
        if(newEmailMessageReceived.contactEmail && newEmailMessageReceived.subject && newEmailMessageReceived.message) {
            PUBLISH(newEmailMessageReceived);
        } else {
            NSLog(@"New Email fields are not supplied.");
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
                                @"From:",
                                @"To:",
                                nil];
    
    for(NSString *textToSplit in textToSplitArray) {
        messageText = [messageText componentsSeparatedByString:textToSplit].firstObject;
    }
    
    messageText = [messageText stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    messageText = [messageText trimmedText];
    
    return messageText;
}

@end
