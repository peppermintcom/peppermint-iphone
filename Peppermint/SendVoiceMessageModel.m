//
//  SendVoiceMessageModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageModel.h"
#import "ConnectionModel.h"
#import "CacheModel.h"
#import "FastReplyModel.h"
#import <Crashlytics/Crashlytics.h>

#define DISPATCH_SEMAPHORE_PERIOD   15000000000 //15seconds in nanoseconds

@implementation SendVoiceMessageModel {
    NSLock *arrayLock;
    SendingStatus _sendingStatus;
    dispatch_semaphore_t dispatch_semaphore;
}

-(id) init {
    self = [super init];
    if(self) {
        arrayLock = [[NSLock alloc] init];
        recentContactsModel = [RecentContactsModel new];
        recentContactsModel.delegate = self;
        self.peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        awsModel = [AWSModel new];
        awsModel.delegate = self;
        dispatch_semaphore = dispatch_semaphore_create(0);
        self.sendingStatus = SendingStatusIniting;
        [awsModel initRecorder];
        customContactModel = [CustomContactModel new];
        customContactModel.delegate = self;
    }
    return self;
}

-(void) dealloc {
    NSLog(@"Dealloc %@ in status %d\n", self, (int)self.sendingStatus);
}

-(void) sendVoiceMessageWithData:(NSData*) data withExtension:(NSString*) extension andDuration:(NSTimeInterval)duration {
    _data = data;
    _extension = extension;
    _duration = duration;
    [recentContactsModel save:self.selectedPeppermintContact];
    [self attachProcessToAppDelegate];
    [self checkAndCleanFastReplyModel];

    if(self.sendingStatus == SendingStatusIniting) {
        dispatch_semaphore_wait(dispatch_semaphore,dispatch_time(DISPATCH_TIME_NOW, DISPATCH_SEMAPHORE_PERIOD));
    }
}

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
    self.sendingStatus = SendingStatusError;
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactSavedSucessfully:(PeppermintContact*) recentContact {
    [self.delegate newRecentContactisSaved];
}

#pragma mark - AWSModelDelegate

-(void) recorderInitIsSuccessful {
    self.sendingStatus = SendingStatusInited;
    dispatch_semaphore_signal(dispatch_semaphore);
}

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    NSLog(@"File Upload is finished with url %@", url);
}

#pragma mark - CustomContactModelDelegate

-(void) customPeppermintContactSavedSucessfully:(PeppermintContact*) peppermintContact {
    NSLog(@"%@ customPeppermintContactSavedSucessfully", peppermintContact.nameSurname);
}

#pragma mark - Type For Extension

-(NSString*) typeForExtension:(NSString*) extension {
    NSString *type = nil;
    if([extension isEqualToString:EXTENSION_M4A]) {
        type = TYPE_M4A;
    } else if ([extension isEqualToString:EXTENSION_AAC]) {
        type = TYPE_AAC;
    } else {
        NSAssert(false, @"MIME Type could not be read!");
    }
    return type;
}

-(BOOL) isServiceAvailable {
    return YES;
}

-(BOOL) needsAuth {
    return NO;
}

-(void) messagePrepareIsStarting {
    self.sendingStatus = SendingStatusStarting;
}

-(void) cacheMessage {
    BOOL isValidToCache = _data && _extension && _duration > 0;
    if(isValidToCache) {
        _sendingStatus = SendingStatusCancelled; //Cancel to stop ongoing processes
        [[CacheModel sharedInstance] cache:self WithData:_data extension:_extension duration:_duration];
    } else {
        NSLog(@"Message could not be cached. There is no sufficient information to cacheq   ""!!!");
    }
}

-(void) cancelSending {
    NSLog(@"Cancelling message for %@", self);
    awsModel.delegate = nil;
    awsModel = nil;
    recentContactsModel = nil;
    self.sendingStatus = SendingStatusCancelled;
}

-(BOOL) isCancelled {
    return self.sendingStatus == SendingStatusCancelled;
}

-(BOOL) isCancelAble {
    return YES;
}

-(NSString*) fastReplyUrlForSender {
    /*
    //Scheme Link
    NSString *urlPath = [NSString stringWithFormat:@"%@://%@?%@=%@&%@=%@",
                         SCHEME_PEPPERMINT,
                         HOST_FASTREPLY,
                         QUERY_COMPONENT_NAMESURNAME,
                         self.peppermintMessageSender.nameSurname,
                         QUERY_COMPONENT_EMAIL,
                         self.peppermintMessageSender.email
                         ];
    */
    
    //Universal Link
    NSString *urlPath = [NSString stringWithFormat:@"https://%@.com/%@?%@=%@&%@=%@",
                         SCHEME_PEPPERMINT,
                         HOST_FASTREPLY,
                         QUERY_COMPONENT_NAMESURNAME,
                         self.peppermintMessageSender.nameSurname,
                         QUERY_COMPONENT_EMAIL,
                         self.peppermintMessageSender.email
                         ];
    
    NSString* encodedUrlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:
                            NSUTF8StringEncoding];
    return encodedUrlPath;
}

#pragma mark - Internet Connection

-(BOOL) isConnectionActive {
    return [[ConnectionModel sharedInstance] isInternetReachable];
}

#pragma mark - Attachment with AppDelegate

-(void) attachProcessToAppDelegate {
    NSMutableArray *array = [AppDelegate Instance].mutableArray;
    if(![array containsObject:self]) {
        NSLog(@"Sending& Attached voice message %@", self);
        [arrayLock lock];
        [array addObject:self];
        [arrayLock unlock];
        AttachSuccess *attachSuccess = [AttachSuccess new];
        attachSuccess.sender = self;
        PUBLISH(attachSuccess);
    } else {
        NSLog(@"Attach is called on a pre-attached item");
    }
}

-(void) checkToDetach {
    switch (self.sendingStatus) {
        case SendingStatusIniting:
        case SendingStatusInited:
        case SendingStatusStarting:
        case SendingStatusUploading:
        case SendingStatusSending:
        case SendingStatusSendingWithNoCancelOption:
            break;
        case SendingStatusError:
            [self cacheMessage];
        case SendingStatusCancelled:
        case SendingStatusCached:
        case SendingStatusSent:
            NSLog(@"%@ changed status to %d, soon it will be detached.", self, (int)self.sendingStatus);
            [self performDetach];
            return;
        default:
            break;
    }
    NSLog(@"Timer checked if %@ is completed. But it is still in %d state", self, (int)self.sendingStatus);
}

-(void) performDetach {
    NSMutableArray *array = [AppDelegate Instance].mutableArray;
    if([array containsObject:self]) {
        [arrayLock lock];
        [array removeObject:self];
        [arrayLock unlock];
        NSLog(@"Comleted& Detached voice message %@ with status %d", self, (int)self.sendingStatus);
        DetachSuccess *detachSuccess = [DetachSuccess new];
        detachSuccess.sender = self;
        PUBLISH(detachSuccess);
    } else {
        NSLog(@"Detach is called on a non-attached item");
    }
}

#pragma mark - Active SendVoiceMessageModel

+(BOOL) isModelActive:(SendVoiceMessageModel *) sendVoiceMessageModel {
    return sendVoiceMessageModel.delegate != nil
    && (sendVoiceMessageModel.sendingStatus == SendingStatusStarting
        || sendVoiceMessageModel.sendingStatus == SendingStatusSending
        || sendVoiceMessageModel.sendingStatus == SendingStatusUploading
        || sendVoiceMessageModel.sendingStatus == SendingStatusSendingWithNoCancelOption);
}

+(SendVoiceMessageModel*) activeSendVoiceMessageModel {
    SendVoiceMessageModel *sendVoiceMessageModel = nil;
    NSMutableArray *array = [AppDelegate Instance].mutableArray;
    
    for(SendVoiceMessageModel *item in array) {
        if(!sendVoiceMessageModel
           || sendVoiceMessageModel.sendingStatus > item.sendingStatus
           || [self isModelActive:item]) {
            sendVoiceMessageModel = item;
        }
    }
    return sendVoiceMessageModel;
}

#pragma mark - FastReplyModel

-(void) checkAndCleanFastReplyModel {
    PeppermintContact *fastReplyContact = [FastReplyModel sharedInstance].peppermintContact;
    if([self.selectedPeppermintContact equals:fastReplyContact]) {
        [customContactModel save:fastReplyContact];
        [[FastReplyModel sharedInstance] cleanFastReplyContact];
    }
}

#pragma mark - SendingStatus

-(void)setSendingStatus:(SendingStatus) sendingStatus {
    if(_sendingStatus != sendingStatus) {
        _sendingStatus = sendingStatus;
        MessageSendingStatusIsUpdated *messageSendingStatusIsUpdated = [MessageSendingStatusIsUpdated new];
        messageSendingStatusIsUpdated.sender = self;
        PUBLISH(messageSendingStatusIsUpdated);
        [self checkToDetach];
    }
}

-(SendingStatus) sendingStatus {
    return _sendingStatus;
}

@end