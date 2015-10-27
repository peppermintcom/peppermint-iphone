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
}

-(id) init {
    self = [super init];
    if(self) {
        rootViewController = [AppDelegate Instance].window.rootViewController;
    }
    return self;
}

-(void) sendVoiceMessageWithData:(NSData *)data withExtension:(NSString *)extension  {
    if(!self.isCancelled) {
        if([self isServiceAvailable]) {
            [super sendVoiceMessageWithData:data withExtension:extension];
            [awsModel startToUploadData:data ofType:[self typeForExtension:extension]];
        } else {
            NSLog(@"Could not proceeed, cos device does not support!");
        }
    } else {
        NSLog(@"SMS message sending is not fired, cos message is cancelled");
    }
}

#pragma mark - AWSModelDelegate

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    NSLog(@"File Upload is finished with url %@", url);
    if(!self.isCancelled) {
        [self fireSMSMessageWithUrl:url];
    } else {
        NSLog(@"Mandrill message sending is not fired, cos message is cancelled");
    }
}

-(void) fireSMSMessageWithUrl:(NSString*) url {
    
    MFMessageComposeViewController *smsComposerVC = [MFMessageComposeViewController new];
    smsComposerVC.messageComposeDelegate = self;
    
    NSArray *recipientsArray = [NSArray arrayWithObjects:self.selectedPeppermintContact.communicationChannelAddress, nil];
    smsComposerVC.recipients = recipientsArray;
    
    if([MFMessageComposeViewController canSendSubject]) {
        smsComposerVC.subject = @"Peppermint";
    }
    
    smsComposerVC.body =  [NSString stringWithFormat:LOC(@"SMS Body Format", @"SMS Body Format"), url];
    [rootViewController presentViewController:smsComposerVC animated:YES completion:nil];
    [self.delegate messageIsSendingWithCancelOption:NO];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
        case MessageComposeResultSent:
            [self.delegate messageSentWithSuccess];
            break;
        case MessageComposeResultCancelled:
            [self.delegate messageIsCancelledByTheUserOutOfApp];
            break;
        case MessageComposeResultFailed:
            [self.delegate operationFailure: [NSError errorWithDomain:@"SMS sending is failed" code:-1 userInfo:nil]];
            break;
        default:
            break;
    }
}

-(BOOL) isServiceAvailable {
    return [MFMessageComposeViewController canSendText];
}

-(void) messagePrepareIsStarting {
    NSLog(@"Do not show sending message");
}

@end
