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
    }
    return self;
}

-(void) cache:(BaseModel*) model WithData:(NSData*) data extension:(NSString*) extension {
    SendVoiceMessageEmailModel *sendVoiceMessageEmailModel = (SendVoiceMessageEmailModel*) model;
    NSAssert(sendVoiceMessageEmailModel != nil, @"Cache message can work just with an instance of SendVoiceMessageEmailModel");
    
    Repository *repository = [Repository beginTransaction];
    CachedMessage *cachedMessage =
    (CachedMessage*)[repository createEntity:[CachedMessage class]];
    cachedMessage.data = data;
    cachedMessage.extension = extension;
    cachedMessage.senderEmail = sendVoiceMessageEmailModel.peppermintMessageSender.email;
    cachedMessage.senderNameSurname = sendVoiceMessageEmailModel.peppermintMessageSender.nameSurname;
    
    cachedMessage.receiverCommunicationChannel = [NSNumber numberWithInt:sendVoiceMessageEmailModel.selectedPeppermintContact.communicationChannel];
    cachedMessage.receiverCommunicationChannelAddress = sendVoiceMessageEmailModel.selectedPeppermintContact.communicationChannelAddress;
    cachedMessage.receiverNameSurname = sendVoiceMessageEmailModel.selectedPeppermintContact.nameSurname;
    cachedMessage.mailSenderClass = [NSString stringWithFormat:@"%@", [sendVoiceMessageEmailModel class]];
    
    NSError *err = [repository endTransaction];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(err) {
            sendVoiceMessageEmailModel.sendingStatus = SendingStatusError;
            [sendVoiceMessageEmailModel.delegate operationFailure:err];
        } else {
            sendVoiceMessageEmailModel.sendingStatus = SendingStatusCached;
            [sendVoiceMessageEmailModel.delegate messageStatusIsUpdated:SendingStatusCached withCancelOption:NO];
        }
    });
}

-(void) triggerCachedMessages {
    @synchronized(self) {
        if(++numberOfActiveCalls == 1) {
            dispatch_async(LOW_PRIORITY_QUEUE, ^() {
                NSLog(@"triggerCachedMessages processing...............");
                Repository *repository = [Repository beginTransaction];
                NSArray *cachedMessageArray =
                [repository getResultsFromEntity:[CachedMessage class]];
                NSLog(@"found %lu voice messages", (unsigned long)cachedMessageArray.count);
                
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
                    
                    while (mailSenderModel.sendingStatus != SendingStatusSent
                           && mailSenderModel.sendingStatus != SendingStatusCancelled
                           && mailSenderModel.sendingStatus != SendingStatusError) {
#warning "Find smarter way than busy waiting" (We may add a status to SendVoiceMessageModel to indicate if it is in background or foreground)
                        //Busy wait...
                    }
                    
                    if(mailSenderModel.sendingStatus == SendingStatusSent || mailSenderModel.sendingStatus == SendingStatusCancelled) {
                        [repository deleteEntity:cachedMessage];
                    } else {
                        NSLog(@"Does not deleting the cachedMessage cos sendingstatus is %d",
                              (int)mailSenderModel.sendingStatus);
                    }
                }
                NSError *error = [repository endTransaction];
                if(error) {
                    NSLog(@"DB errror %@", error.description);
                } else {
                    if(--numberOfActiveCalls > 0) {
                        NSLog(@"recalled %lu times while sending cached messages!!!", (unsigned long)numberOfActiveCalls);
                        numberOfActiveCalls = 0;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[CacheModel sharedInstance] triggerCachedMessages];
                        });
                    }
                }
            });
        } else {
            NSLog(@"Did not process triggerCachedMessages. Marked as called again!");
        }
    }
}

-(void) cacheOngoingMessages {
    NSArray *ongoingMessagesArray = [AppDelegate Instance].mutableArray;
    if(ongoingMessagesArray.count > 0 ) {
        NSLog(@"Terminating the app& Still it exists %lu items\nCaching the ongoing messages.", ongoingMessagesArray.count);
        for (SendVoiceMessageModel *sendVoiceMessageModel in ongoingMessagesArray) {
            if(sendVoiceMessageModel.delegate) {
                [sendVoiceMessageModel cacheMessage];
            }
        }
    }
}

@end
