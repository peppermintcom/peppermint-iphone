//
//  SendVoiceMessageEmailModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageEmailModel.h"
#import <MessageUI/MessageUI.h>
#import "EasyMailSender.h"
#import "EasyMailAlertSender.h"

@implementation SendVoiceMessageEmailModel

-(void) sendVoiceMessageWithData:(NSData*) data {
    EasyMailAlertSender *mailSender = [EasyMailAlertSender easyMail:^(MFMailComposeViewController *controller) {
        [controller setToRecipients:[NSArray arrayWithObject:self.selectedPeppermintContact.communicationChannelAddress]];
        [controller setSubject:LOC(@"Mail Subject",@"Default Mail Subject")];
        [controller setMessageBody:LOC(@"Mail Body",@"Default Mail Body") isHTML:YES];
        [controller addAttachmentData:data mimeType:@"audio/mp4" fileName:@"Peppermint.m4a"];
    } complete:^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error) {
        
        if(error) {
            [controller dismissViewControllerAnimated:YES completion:nil];
            [self.delegate operationFailure:error];
        } else if (result == MFMailComposeResultFailed) {
            [controller dismissViewControllerAnimated:YES completion:nil];
            error = [NSError errorWithDomain:LOC(@"An error occured",@"Unknown Error Message") code:0 userInfo:nil];
            [self.delegate operationFailure:error];
        } else if (result == MFMailComposeResultSent) {
            [super sendVoiceMessageWithData:data];
            [self.delegate messageSentWithSuccess];
            [controller dismissViewControllerAnimated:NO completion:nil];
        } else {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    UIViewController *activeViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.delegate messageIsSending];
    [mailSender showFromViewController:activeViewController];
}

+ (BOOL)canDeviceSendEmail
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    return mailClass != nil && [MFMailComposeViewController canSendMail];
}

@end
