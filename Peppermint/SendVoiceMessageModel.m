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

#define TIMER_PERIOD    3

@implementation SendVoiceMessageModel {
    NSTimer *timer;
    NSLock *arrayLock;
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
        self.sendingStatus = SendingStatusIniting;
        [awsModel initRecorder];
        timer = nil;
    }
    return self;
}

-(void) dealloc {
    if(self.sendingStatus != SendingStatusCached
       && self.sendingStatus != SendingStatusCancelled
       && self.sendingStatus != SendingStatusError
       && self.sendingStatus != SendingStatusInited
       && self.sendingStatus != SendingStatusIniting
       && self.sendingStatus != SendingStatusSent
       ) {
        NSLog(@"Dealloc a sendVoiceMessageModel during %d state", (int)self.sendingStatus);
    }
}

-(void) sendVoiceMessageWithData:(NSData*) data withExtension:(NSString*) extension {
    _data = data;
    _extension = extension;
    [recentContactsModel save:self.selectedPeppermintContact];
    [self attachProcessToAppDelegate];
    [self checkAndCleanFastReplyModel];
    
#warning "Busy wait, think to make it with a more smart way"
    if(self.sendingStatus == SendingStatusIniting) {
        while (self.sendingStatus != SendingStatusInited ) {
            NSLog(@"waiting aws model to be ready!");
        }
    }
}

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
    self.sendingStatus = SendingStatusError;
    [self cacheMessage];
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactSavedSucessfully:(PeppermintContact*) recentContact {
    [self.delegate newRecentContactisSaved];
}

#pragma mark - AWSModelDelegate

-(void) recorderInitIsSuccessful {
    self.sendingStatus = SendingStatusInited;
}

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    //NSLog(@"File Upload is finished with url %@", url);
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
    [self.delegate messageStatusIsUpdated:SendingStatusStarting withCancelOption:YES];
}

-(void) cacheMessage {
    if(self.delegate) {
        [[CacheModel sharedInstance] cache:self WithData:_data extension:_extension];
        NSLog(@"Message is cached.");
        [self.delegate messageStatusIsUpdated:self.sendingStatus withCancelOption:NO];
    } else {
        NSLog(@"not cached...");
    }
}

-(void) cancelSending {
    NSLog(@"Cancelling!");
    awsModel.delegate = nil;
    awsModel = nil;
    recentContactsModel = nil;
    self.sendingStatus = SendingStatusCancelled;
}

-(BOOL) isCancelled {
    return self.sendingStatus == SendingStatusCancelled;
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
        NSLog(@"Attached and timer started!!");
        [arrayLock lock];
        [array addObject:self];
        [arrayLock unlock];
        if(timer) { [timer invalidate]; NSLog(@"invalidated a timer!!"); }
        timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_PERIOD target:self selector:@selector(detachProcessFromAppDelegate) userInfo:nil repeats:YES];
        timer.tolerance = TIMER_PERIOD * 0.1;
        
    } else {
        NSLog(@"Attach is called on a pre-attached item");
    }
}

-(void) detachProcessFromAppDelegate {
    NSLog(@"Check for detach!");
    if(self.sendingStatus == SendingStatusError
       || self.sendingStatus == SendingStatusCancelled
       || self.sendingStatus == SendingStatusIniting
       || self.sendingStatus == SendingStatusInited
       || self.sendingStatus == SendingStatusCached
       || self.sendingStatus == SendingStatusSent
       ) {
        [timer invalidate];
        timer = nil;
        NSLog(@"trigger detach");
        
        NSString *contentName = [NSString stringWithFormat:@"%lu bytes", (unsigned long)_data.length];
        [Answers logShareWithMethod:@"SendVoiceMessage" contentName:contentName contentType:_extension contentId:self.description customAttributes:nil];
        [self performSelector:@selector(performDetach) withObject:nil afterDelay:TIMER_PERIOD*2];
    }
    
}

-(void) performDetach {
    NSMutableArray *array = [AppDelegate Instance].mutableArray;
    if([array containsObject:self]) {
        [arrayLock lock];
        [array removeObject:self];
        [arrayLock unlock];
        NSLog(@"Detached!!");
        
        DetachSuccess *detachSuccess = [DetachSuccess new];
        detachSuccess.sender = self;
        PUBLISH(detachSuccess);
    } else {
        NSLog(@"Detach is called on a non-attached item");
    }
}

#pragma mark - Active SendVoiceMessageModel

+(SendVoiceMessageModel*) activeSendVoiceMessageModel {
    SendVoiceMessageModel *sendVoiceMessageModel = nil;
    NSMutableArray *array = [AppDelegate Instance].mutableArray;
    for(SendVoiceMessageModel *item in array) {
        if(!sendVoiceMessageModel
           || sendVoiceMessageModel.sendingStatus > item.sendingStatus) {
            sendVoiceMessageModel = item;
        }
    }
    return sendVoiceMessageModel;
}

#pragma mark - FastReplyModel

-(void) checkAndCleanFastReplyModel {
    PeppermintContact *fastReplyContact = [FastReplyModel sharedInstance].peppermintContact;
    if([self.selectedPeppermintContact equals:fastReplyContact]) {
        [[FastReplyModel sharedInstance] cleanFastReplyContact];
    }
}

@end
