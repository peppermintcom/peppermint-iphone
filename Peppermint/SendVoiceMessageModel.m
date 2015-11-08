//
//  SendVoiceMessageModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageModel.h"
#import "ConnectionModel.h"

@implementation SendVoiceMessageModel {
    ConnectionModel *connectionModel;
}

-(id) init {
    self = [super init];
    if(self) {
        recentContactsModel = [RecentContactsModel new];
        recentContactsModel.delegate = self;
        self.peppermintMessageSender = [PeppermintMessageSender new];
        awsModel = [AWSModel new];
        awsModel.delegate = self;
        self.sendingStatus = SendingStatusIniting;
        [awsModel initRecorder];
        connectionModel = [ConnectionModel new];
        [connectionModel beginTracking];
    }
    return self;
}

-(void) dealloc {
    [connectionModel stopTracking];
}

-(void) sendVoiceMessageWithData:(NSData*) data withExtension:(NSString*) extension {
    [recentContactsModel save:self.selectedPeppermintContact];
#warning "Busy wait, think to make it with a more smart way"
    if(self.sendingStatus == SendingStatusIniting) {
        while (self.sendingStatus != SendingStatusInited ) {
            NSLog(@"waiting aws model to be ready!");
        }
    }
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactSavedSucessfully:(PeppermintContact*) recentContact {
    //Contact is saved...
}

-(void) operationFailure:(NSError*) error {
    self.sendingStatus = SendingStatusError;
    [self.delegate operationFailure:error];
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

SUBSCRIBE(NetworkFailure) {
    self.sendingStatus = SendingStatusError;
    [self.delegate operationFailure:[event error]];
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
    NSString *urlPath = [NSString stringWithFormat:@"%@://%@?%@=%@&%@=%@",
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
    return [connectionModel isInternetReachable];
}

@end
