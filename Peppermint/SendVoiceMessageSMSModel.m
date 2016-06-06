//
//  SendVoiceMessageSMSModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 25/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageSMSModel.h"

@implementation SendVoiceMessageSMSModel {
    UIViewController *rootViewController;
    NSString *cachedUrl;
}

-(id) init {
    self = [super init];
    if(self) {
        rootViewController = [AppDelegate Instance].window.rootViewController;
    }
    return self;
}

-(void) sendVoiceMessageWithData:(NSData *)data withExtension:(NSString *)extension andDuration:(NSTimeInterval)duration {    
    BOOL isSMSSendingAvailable = IS_SMS_SENDING_AVAILABLE;
    if(!isSMSSendingAvailable) {
        NSLog(@"\n\n\n");
        NSLog(@"*******************************************");
        NSLog(@"*********SMS SENDING IS BYPASSED***********");
        NSLog(@"*******************************************\n\n\n");
        return;
    } else if(![self isCancelled]) {
        if([self isServiceAvailable]) {
            [super sendVoiceMessageWithData:data withExtension:extension andDuration:duration];
            self.sendingStatus = SendingStatusUploading;
            [awsModel startToUploadData:data ofType:[self typeForExtension:extension]];
        } else {
            NSLog(@"Could not proceeed, cos device does not support!");
        }
    } else {
        NSLog(@"SMS message sending is not fired, cos message is cancelled");
    }
    
}

#pragma mark - AWSModelDelegate

-(void) fileUploadStartedWithPublicUrl:(NSString*) url canonicalUrl:(NSString*)canonicalUrl {
    cachedUrl = url;
    [super fileUploadStartedWithPublicUrl:url canonicalUrl:canonicalUrl];
}

-(void) uploadsAreProcessedToSendMessage {
    if(![self isCancelled]) {
        [self fireSMSMessageWithUrl:cachedUrl];
    } else {
        NSLog(@"Mandrill message sending is not fired, cos message is cancelled");
    }
}

-(void) fireSMSMessageWithUrl:(NSString*) url {
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self cacheMessage];
    } else {
        MFMessageComposeViewController *smsComposerVC = [MFMessageComposeViewController new];
        smsComposerVC.messageComposeDelegate = self;
        
        NSArray *recipientsArray = [NSArray arrayWithObjects:self.selectedPeppermintContact.communicationChannelAddress, @"?", nil];
        smsComposerVC.recipients = recipientsArray;
        smsComposerVC.body =  [NSString stringWithFormat:LOC(@"SMS Body Format", @"SMS Body Format"), url];
        [smsComposerVC disableUserAttachments];
        self.sendingStatus = SendingStatusUploading;
        weakself_create();
        [rootViewController presentViewController:smsComposerVC animated:YES completion:^{
            weakSelf.sendingStatus = SendingStatusSendingWithNoCancelOption;
        }];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            self.sendingStatus = SendingStatusSent;
            break;
        case MessageComposeResultCancelled:
            self.sendingStatus = SendingStatusCancelled;
            break;
        case MessageComposeResultFailed:
            self.sendingStatus = SendingStatusError;
            [self.delegate operationFailure: [NSError errorWithDomain:@"SMS sending is failed" code:-1 userInfo:nil]];
            break;
        default:
            break;
    }
}

-(BOOL) isServiceAvailable {    
    return [MFMessageComposeViewController canSendText];
}

-(BOOL) isCancelAble {
    return
    self.sendingStatus == SendingStatusStarting
    || self.sendingStatus == SendingStatusUploading;
}

@end
