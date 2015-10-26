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
        if([MFMessageComposeViewController canSendText]) {
            [super sendVoiceMessageWithData:data withExtension:extension];
            [self.delegate messageIsSendingWithCancelOption:YES];
            [self fireSMSMessageWithData:data ofExtension:extension];
        } else {
            NSLog(@"Could not proceeed, cos device does not support!");
        }
    } else {
        NSLog(@"SMS message sending is not fired, cos message is cancelled");
    }
}

-(void) fireSMSMessageWithData:(NSData*) data ofExtension:(NSString*) extension {
    
    MFMessageComposeViewController *smsComposerVC = [MFMessageComposeViewController new];
    smsComposerVC.messageComposeDelegate = self;
    
    NSArray *recipientsArray = [NSArray arrayWithObjects:self.selectedPeppermintContact.communicationChannelAddress, nil];
    smsComposerVC.recipients = recipientsArray;
    
    if([MFMessageComposeViewController canSendSubject]) {
        smsComposerVC.subject = @"Peppermint";
    }
    
    smsComposerVC.body = LOC(@"SMS Body", @"SMS Body");;
    [smsComposerVC addAttachmentData:data typeIdentifier:@"public.audio" filename:[NSString stringWithFormat:@"Peppermint.%@", extension]];
    
    [self.delegate messageIsSendingWithCancelOption:NO];
    [rootViewController presentViewController:smsComposerVC animated:YES completion:nil];
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

@end
