//
//  CacheModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 07/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "CacheModel.h"
#import "SendVoiceMessageEmailModel.h"

#define DBQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

@implementation CacheModel {
    volatile NSUInteger numberOfActiveCalls;
}

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
        numberOfActiveCalls = 0;
        REGISTER();
    }
    return self;
}

-(void) cache:(SendVoiceMessageModel*) sendVoiceMessageModel WithData:(NSData*) data extension:(NSString*) extension {
    
    Repository *repository = [Repository beginTransaction];
    CachedMessage *cachedMessage =
    (CachedMessage*)[repository createEntity:[CachedMessage class]];
    cachedMessage.data = data;
    cachedMessage.extension = extension;
    cachedMessage.senderEmail = sendVoiceMessageModel.peppermintMessageSender.email;
    cachedMessage.senderNameSurname = sendVoiceMessageModel.peppermintMessageSender.nameSurname;
    
    cachedMessage.receiverCommunicationChannel = [NSNumber numberWithInt:sendVoiceMessageModel.selectedPeppermintContact.communicationChannel];
    cachedMessage.receiverCommunicationChannelAddress = sendVoiceMessageModel.selectedPeppermintContact.communicationChannelAddress;
    cachedMessage.receiverNameSurname = sendVoiceMessageModel.selectedPeppermintContact.nameSurname;
    cachedMessage.mailSenderClass = [NSString stringWithFormat:@"%@", [sendVoiceMessageModel class]];
    
    __block NSError *err = [repository endTransaction];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(err) {
            NSLog(@"Error during caching message");
            sendVoiceMessageModel.sendingStatus = SendingStatusError;
            [sendVoiceMessageModel.delegate operationFailure:err];
        } else {
            NSLog(@"Message %@ is cached successfully!", sendVoiceMessageModel);
            sendVoiceMessageModel.sendingStatus = SendingStatusCached;
            [sendVoiceMessageModel.delegate messageStatusIsUpdated:SendingStatusCached];
        }
    });
}


SUBSCRIBE(ApplicationDidBecomeActive) {
    [self triggerCachedMessages];
}

-(void) triggerCachedMessages {
    NSLog(@"triggerCachedMessages function is called");
        if(++numberOfActiveCalls == 1) {
            dispatch_async(LOW_PRIORITY_QUEUE, ^() {
                Repository *repository = [Repository beginTransaction];
                NSArray *cachedMessageArray =
                [repository getResultsFromEntity:[CachedMessage class]];
                
                NSLog(@"Now, there is %lu nontriggered cached voice messages", (unsigned long)cachedMessageArray.count);
                
                for(int i=0; i<cachedMessageArray.count; i++) {
                    CachedMessage *cachedMessage = [cachedMessageArray objectAtIndex:i];
                    SendVoiceMessageEmailModel *mailSenderModel = [[NSClassFromString(cachedMessage.mailSenderClass) alloc] init];
                    mailSenderModel.delegate = nil;
                    
                    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
                    peppermintMessageSender.nameSurname = cachedMessage.senderNameSurname;
                    peppermintMessageSender.email = cachedMessage.senderEmail;
                    PeppermintContact *selectedContact = [PeppermintContact new];
                    selectedContact.nameSurname = cachedMessage.receiverNameSurname;
                    selectedContact.communicationChannel = cachedMessage.receiverCommunicationChannel.intValue;
                    selectedContact.communicationChannelAddress = cachedMessage.receiverCommunicationChannelAddress;
                    mailSenderModel.peppermintMessageSender = peppermintMessageSender;
                    mailSenderModel.selectedPeppermintContact = selectedContact;
                    
                    [mailSenderModel sendVoiceMessageWithData:cachedMessage.data withExtension:cachedMessage.extension];
                    [repository deleteEntity:cachedMessage];
                }
                [repository endTransaction];
                if(--numberOfActiveCalls > 0) {
                    NSLog(@"recalled %lu times while sending cached messages!!!", (unsigned long)numberOfActiveCalls);
                    numberOfActiveCalls = 0;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[CacheModel sharedInstance] triggerCachedMessages];
                    });
                }
            });
        } else {
            NSLog(@"called triggerCachedMessages function is marked to called again on complete!");
        }
}

-(void) cacheOngoingMessages {
    NSArray *ongoingMessagesArray = [AppDelegate Instance].mutableArray;
    if(ongoingMessagesArray.count > 0 ) {
        NSLog(@"Terminating the app& Still it exists %lu items\nCaching the ongoing messages.", (unsigned long)ongoingMessagesArray.count);
        
        for (SendVoiceMessageModel *sendVoiceMessageModel in ongoingMessagesArray) {
            switch (sendVoiceMessageModel.sendingStatus) {
                case SendingStatusIniting:
                case SendingStatusInited:
                case SendingStatusStarting:
                case SendingStatusUploading:
                case SendingStatusError:
                case SendingStatusSending:
                    [sendVoiceMessageModel cacheMessage];
                    break;
                case SendingStatusSendingWithNoCancelOption:
                case SendingStatusCancelled:
                case SendingStatusCached:
                case SendingStatusSent:
                    NSLog(@"Did not cache message, cos the status is already %d", (int)sendVoiceMessageModel.sendingStatus);
                    break;
                default:
                    break;
            }
        }
    }
}

@end
