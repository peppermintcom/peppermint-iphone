//
//  SendVoiceMessageModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageModel.h"

@implementation SendVoiceMessageModel

-(id) init {
    self = [super init];
    if(self) {
        recentContactsModel = [RecentContactsModel new];
        recentContactsModel.delegate = self;
        self.peppermintMessageSender = [PeppermintMessageSender new];
        awsModel = [AWSModel new];
        awsModel.delegate = self;
        [awsModel initRecorder];
        isCancelled = NO;
    }
    return self;
}

-(void) sendVoiceMessageWithData:(NSData*) data withExtension:(NSString*) extension {
    [recentContactsModel save:self.selectedPeppermintContact];
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactSavedSucessfully:(PeppermintContact*) recentContact {
    //Contact is saved...
}

-(void) operationFailure:(NSError*) error {
    [self.delegate operationFailure:error];
}

#pragma mark - AWSModelDelegate
-(void) recorderInitIsSuccessful {
    NSLog(@"awsrecorder is inited!");
}

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    NSLog(@"File Upload is finished with url %@", url);
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
    [self.delegate operationFailure:[event error]];
}

-(BOOL) isServiceAvailable {
    return YES;
}

-(BOOL) needsAuth {
    return NO;
}

-(void) messagePrepareIsStarting {
    [self.delegate messageIsSendingWithCancelOption:YES];
}

-(void) cancelSending {
    NSLog(@"Cancelling!");
    awsModel.delegate = nil;
    awsModel = nil;
    recentContactsModel = nil;
    isCancelled = YES;
}

@end
