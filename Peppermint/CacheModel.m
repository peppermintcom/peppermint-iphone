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
    BOOL isEmailContact =
    sendVoiceMessageEmailModel.selectedPeppermintContact.communicationChannel == CommunicationChannelEmail;
    NSAssert(isEmailContact, @"Cache message can work just for email contacts");
    
    dispatch_async(DBQueue, ^() {
        Repository *repository = [Repository beginTransaction];
        CachedEmailMessage *cachedEmailMessage =
        (CachedEmailMessage*)[repository createEntity:[CachedEmailMessage class]];
        cachedEmailMessage.data = data;
        cachedEmailMessage.extension = extension;
        cachedEmailMessage.senderEmail = sendVoiceMessageEmailModel.peppermintMessageSender.email;
        cachedEmailMessage.senderNameSurname = sendVoiceMessageEmailModel.peppermintMessageSender.nameSurname;
        cachedEmailMessage.receiverEmail = sendVoiceMessageEmailModel.selectedPeppermintContact.communicationChannelAddress;
        cachedEmailMessage.receiverNameSurname = sendVoiceMessageEmailModel.selectedPeppermintContact.nameSurname;
        cachedEmailMessage.mailSenderClass = [NSString stringWithFormat:@"%@", [sendVoiceMessageEmailModel class]];
        
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
    });
}

-(void) triggerCachedMessages {
    @synchronized(self) {
        if(++numberOfActiveCalls == 1) {
            dispatch_async(DBQueue, ^() {
                NSLog(@"triggerCachedMessages processing...............");
                Repository *repository = [Repository beginTransaction];
                NSArray *cachedEmailMessageArray =
                [repository getResultsFromEntity:[CachedEmailMessage class]];
                NSLog(@"found %lu voice messages", cachedEmailMessageArray.count);
                
                for(int i=0; i<cachedEmailMessageArray.count; i++) {
                    CachedEmailMessage *cachedEmailMessage = [cachedEmailMessageArray objectAtIndex:i];
                    SendVoiceMessageEmailModel *mailSenderModel = [[NSClassFromString(cachedEmailMessage.mailSenderClass) alloc] init];
                    mailSenderModel.delegate = nil;
                    
                    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
                    peppermintMessageSender.nameSurname = cachedEmailMessage.senderNameSurname;
                    peppermintMessageSender.email = cachedEmailMessage.senderEmail;
                    PeppermintContact *selectedContact = [PeppermintContact new];
                    selectedContact.nameSurname = cachedEmailMessage.receiverNameSurname;
                    selectedContact.communicationChannelAddress = cachedEmailMessage.receiverEmail;
                    mailSenderModel.peppermintMessageSender = peppermintMessageSender;
                    mailSenderModel.selectedPeppermintContact = selectedContact;
                    
                    [mailSenderModel sendVoiceMessageWithData:cachedEmailMessage.data withExtension:cachedEmailMessage.extension];
                    
                    while (mailSenderModel.sendingStatus != SendingStatusSent
                           && mailSenderModel.sendingStatus != SendingStatusCancelled
                           && mailSenderModel.sendingStatus != SendingStatusError) {
#warning "Find smarter way than busy waiting"
                        //Busy wait...
                    }
                    
                    if(mailSenderModel.sendingStatus == SendingStatusSent) {
                        [repository deleteEntity:cachedEmailMessage];
                    } else {
                        NSLog(@"Does not deleting the cachedEmailMessage cos sendingstatus is %d",
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

@end
