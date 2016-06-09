//
//  CacheModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 07/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "CacheModel.h"
#import "SendVoiceMessageEmailModel.h"
#import "ConnectionModel.h"

#define DBQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

#define     KEY_NAME_SURNAME                    @"NameSurname"
#define     KEY_COMMUNICATION_CHANNEL           @"CommunicationChannel"
#define     KEY_COMMUNICATION_CHANNEL_ADDRESS   @"CommunicationChannelAddress"
#define     KEY_SENDER_CLASS                    @"SenderClass"

@implementation CacheModel {
    __block volatile NSUInteger numberOfActiveCalls;
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

-(void) cache:(SendVoiceMessageModel*) sendVoiceMessageModel WithData:(NSData*) data extension:(NSString*) extension duration:(NSTimeInterval)duration transcriptionInfo:(TranscriptionInfo*)transcriptionInfo {
    
    Repository *repository = [Repository beginTransaction];
    CachedMessage *cachedMessage =
    (CachedMessage*)[repository createEntity:[CachedMessage class]];
    cachedMessage.data = data;
    cachedMessage.extension = extension;
    cachedMessage.senderEmail = sendVoiceMessageModel.peppermintMessageSender.email;
    cachedMessage.senderNameSurname = sendVoiceMessageModel.peppermintMessageSender.nameSurname;
    if([sendVoiceMessageModel isKindOfClass:[SendVoiceMessageEmailModel class]]) {
        SendVoiceMessageEmailModel *sendVoiceMessageEmailModel = (SendVoiceMessageEmailModel*)sendVoiceMessageModel;
        cachedMessage.subject = sendVoiceMessageEmailModel.subject;
    } else {
        cachedMessage.subject = nil;
    }
    
    cachedMessage.receiverCommunicationChannel = [NSNumber numberWithInt:sendVoiceMessageModel.selectedPeppermintContact.communicationChannel];
    cachedMessage.receiverCommunicationChannelAddress = sendVoiceMessageModel.selectedPeppermintContact.communicationChannelAddress;
    cachedMessage.receiverNameSurname = sendVoiceMessageModel.selectedPeppermintContact.nameSurname;
    cachedMessage.mailSenderClass = [NSString stringWithFormat:@"%@", [sendVoiceMessageModel class]];
    cachedMessage.duration = [NSNumber numberWithDouble:duration];
    cachedMessage.rawAudioData = transcriptionInfo.rawAudioData;
    cachedMessage.transcriptionText = transcriptionInfo.text;
    cachedMessage.retryCount = [NSNumber numberWithInteger:sendVoiceMessageModel.retryCount];
    
    __block NSError *err = [repository endTransaction];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(err) {
            NSLog(@"Error during caching message");
            sendVoiceMessageModel.sendingStatus = SendingStatusError;
            [sendVoiceMessageModel.delegate operationFailure:err];
        } else {
            NSLog(@"Message %@ is cached successfully!", sendVoiceMessageModel);
            sendVoiceMessageModel.sendingStatus = SendingStatusCached;
        }
    });
}


SUBSCRIBE(ApplicationDidBecomeActive) {
    if([[ConnectionModel sharedInstance] isInternetReachable]) {
        [self triggerCachedMessages];
    }
}

-(void) triggerCachedMessages {
    if(++numberOfActiveCalls == 1) {
            dispatch_async(LOW_PRIORITY_QUEUE, ^() {
                Repository *repository = [Repository beginTransaction];
                NSArray *cachedMessageArray =
                [repository getResultsFromEntity:[CachedMessage class]];
                
                for(int i=0; i<cachedMessageArray.count; i++) {
                    CachedMessage *cachedMessage = [cachedMessageArray objectAtIndex:i];
                    if(cachedMessage.retryCount.integerValue < MAX_RETRY_COUNT) {
                        SendVoiceMessageModel *vocieSenderModel = [[NSClassFromString(cachedMessage.mailSenderClass) alloc] init];
                        vocieSenderModel.delegate = nil;
                        vocieSenderModel.isCachedMessage = YES;
                        
                        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
                        peppermintMessageSender.nameSurname = cachedMessage.senderNameSurname;
                        peppermintMessageSender.email = cachedMessage.senderEmail;
                        PeppermintContact *selectedContact = [PeppermintContact new];
                        selectedContact.nameSurname = cachedMessage.receiverNameSurname;
                        selectedContact.communicationChannel = cachedMessage.receiverCommunicationChannel.intValue;
                        selectedContact.communicationChannelAddress = cachedMessage.receiverCommunicationChannelAddress;
                        vocieSenderModel.peppermintMessageSender = peppermintMessageSender;
                        vocieSenderModel.selectedPeppermintContact = selectedContact;
                        vocieSenderModel.transcriptionInfo.rawAudioData = cachedMessage.rawAudioData;
                        vocieSenderModel.transcriptionInfo.text = cachedMessage.transcriptionText;
                        vocieSenderModel.retryCount = cachedMessage.retryCount.integerValue;
                        
                        if ([vocieSenderModel isKindOfClass:[SendVoiceMessageEmailModel class]]) {
                            ((SendVoiceMessageEmailModel*)vocieSenderModel).subject = cachedMessage.subject;
                        }
                        
                        [vocieSenderModel sendVoiceMessageWithData:cachedMessage.data withExtension:cachedMessage.extension  andDuration:cachedMessage.duration.doubleValue];
                        [repository deleteEntity:cachedMessage];
                    } else {
                        NSLog(@"Cached message %@ is not triggered because %ld retryCount reached",
                              cachedMessage.receiverCommunicationChannelAddress,
                              cachedMessage.retryCount.integerValue);
                    }
                }
                [repository endTransaction];
                if(--numberOfActiveCalls > 0) {
                    numberOfActiveCalls = 0;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[CacheModel sharedInstance] triggerCachedMessages];
                    });
                }
            });
    } else {
        NSLog(@"did not process triggerCachedMessages because numberOfActiveCalls is %ld", numberOfActiveCalls);
    }
}

-(void) cacheOngoingMessages {
    NSArray *ongoingMessagesArray = [NSArray arrayWithArray:[AppDelegate Instance].mutableArray];
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


#pragma mark - Cache On Defaults

-(void) cacheOnDefaults:(SendVoiceMessageModel*) sendVoiceMessageModel {
    NSString *nameSurname = sendVoiceMessageModel.selectedPeppermintContact.nameSurname;
    NSNumber *communicationChannel = [NSNumber numberWithInt:sendVoiceMessageModel.selectedPeppermintContact.communicationChannel];
    NSString *communicationChannelAddress = sendVoiceMessageModel.selectedPeppermintContact.communicationChannelAddress;
    NSString *senderClass = [NSString stringWithFormat:@"%@", [sendVoiceMessageModel class]];
    
    NSDictionary *senderDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                nameSurname,                    KEY_NAME_SURNAME,
                                communicationChannel,           KEY_COMMUNICATION_CHANNEL,
                                communicationChannelAddress,    KEY_COMMUNICATION_CHANNEL_ADDRESS,
                                senderClass,                    KEY_SENDER_CLASS,
                                nil];
    
    defaults_set_object(DEFAULTS_KEY_CACHED_SENDVOCIEMESSAGE_MODEL, senderDictionary);
}

-(SendVoiceMessageModel*) cachedSendVoiceMessageModelFromDefaults {
    SendVoiceMessageModel *sendVoiceMessageModel = nil;
    NSDictionary *senderDictionary = defaults_object(DEFAULTS_KEY_CACHED_SENDVOCIEMESSAGE_MODEL);
    if(senderDictionary) {
        PeppermintContact *peppermintContact = [PeppermintContact new];
        peppermintContact.nameSurname = [senderDictionary objectForKey:KEY_NAME_SURNAME];
        peppermintContact.communicationChannel =  [(NSNumber*)[senderDictionary objectForKey:KEY_COMMUNICATION_CHANNEL] integerValue];
        peppermintContact.communicationChannelAddress = [senderDictionary objectForKey:KEY_COMMUNICATION_CHANNEL_ADDRESS];
        
        sendVoiceMessageModel = [[NSClassFromString([senderDictionary objectForKey:KEY_SENDER_CLASS]) alloc] init];
        sendVoiceMessageModel.selectedPeppermintContact = peppermintContact;
    }
    return sendVoiceMessageModel;
}

@end
