//
//  SendVoiceMessageEmailModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 06/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageEmailModel.h"
#import "ConnectionModel.h"

#define DBQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

@implementation SendVoiceMessageEmailModel {
    ConnectionModel *connectionModel;
}

-(id) init {
    self = [super init];
    if(self) {
        connectionModel = [ConnectionModel new];
        [connectionModel beginTracking];
        self.isMessageProcessCompleted = NO;
    }
    return self;
}

-(void) dealloc {
    [connectionModel stopTracking];
}

-(BOOL) isConnectionActive {
    return [connectionModel isInternetReachable];
}

-(void) cacheMessage {
    BOOL isEmailContact =
    self.selectedPeppermintContact.communicationChannel == CommunicationChannelEmail;
    NSAssert(isEmailContact, @"Cache message can work just for email contacts");
    
    dispatch_async(DBQueue, ^() {
        Repository *repository = [Repository beginTransaction];
        CachedEmailMessage *cachedEmailMessage =
        (CachedEmailMessage*)[repository createEntity:[CachedEmailMessage class]];
        cachedEmailMessage.data = _data;
        cachedEmailMessage.extension = _extension;
        cachedEmailMessage.senderEmail = self.peppermintMessageSender.email;
        cachedEmailMessage.senderNameSurname = self.peppermintMessageSender.nameSurname;
        cachedEmailMessage.receiverEmail = self.selectedPeppermintContact.communicationChannelAddress;
        cachedEmailMessage.receiverNameSurname = self.selectedPeppermintContact.nameSurname;
        cachedEmailMessage.mailSenderClass = [NSString stringWithFormat:@"%@", [self class]];
        
        NSError *err = [repository endTransaction];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(err) {
                [self.delegate operationFailure:err];
            } else {
                [self.delegate messageStatusIsUpdated:SendingStatusCached withCancelOption:NO];
            }
        });
    });
}

+(void) triggerCachedMessages {
    dispatch_async(DBQueue, ^() {
        Repository *repository = [Repository beginTransaction];
        NSArray *cachedEmailMessageArray =
        [repository getResultsFromEntity:[CachedEmailMessage class]];
        [repository endTransaction];
        
        for(int i=0; i<cachedEmailMessageArray.count; i++) {
            CachedEmailMessage *cachedEmailMessage = [cachedEmailMessageArray objectAtIndex:i];
            SendVoiceMessageEmailModel *mailSenderModel = [[NSClassFromString(cachedEmailMessage.mailSenderClass) alloc] init];
            mailSenderModel.delegate = nil;
            
            PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender new];
            peppermintMessageSender.nameSurname = cachedEmailMessage.senderNameSurname;
            peppermintMessageSender.email = cachedEmailMessage.senderEmail;
            PeppermintContact *selectedContact = [PeppermintContact new];
            selectedContact.nameSurname = cachedEmailMessage.receiverNameSurname;
            selectedContact.communicationChannelAddress = cachedEmailMessage.receiverEmail;
            mailSenderModel.peppermintMessageSender = peppermintMessageSender;
            mailSenderModel.selectedPeppermintContact = selectedContact;
            
            [mailSenderModel sendVoiceMessageWithData:cachedEmailMessage.data withExtension:cachedEmailMessage.extension];
            
            
            NSLog(@"Sedning %d/%d message", i, cachedEmailMessageArray.count);
            NSInteger messageId = cachedEmailMessage.data.length;
            NSLog(@"waiting model to send message %d", messageId );
            while (!mailSenderModel.isMessageProcessCompleted) {}
            NSLog(@"Sent message %d", messageId);
            
            NSLog(@"Delete the cached file!!!");
        }
    });
}

@end
