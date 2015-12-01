//
//  SendVoiceMessageMailComposerModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageMailComposerModel.h"
#import <MessageUI/MessageUI.h>
#import "EasyMailSender.h"
#import "EasyMailAlertSender.h"

@implementation SendVoiceMessageMailComposerModel

-(void) sendVoiceMessageWithData:(NSData *)data withExtension:(NSString *)extension  {
    
    if([self isConnectionActive]) {
        EasyMailAlertSender *mailSender = [EasyMailAlertSender easyMail:^(MFMailComposeViewController *controller) {
            [controller setToRecipients:[NSArray arrayWithObject:self.selectedPeppermintContact.communicationChannelAddress]];

            NSString *signature = @"";
            PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
            if (peppermintMessageSender.signature.length > 0) {
                signature = peppermintMessageSender.signature;
            }
            
            [controller setSubject:[PeppermintMessageSender sharedInstance].subject];
            NSString *textBody = [NSString stringWithFormat:LOC(@"Mail Text Format",@"Default Mail Text Format"), @"", [self fastReplyUrlForSender], signature];
            [controller setMessageBody:textBody isHTML:NO];
            NSString *body = [self mailBodyHTMLForUrlPath:nil extension:nil signature:signature];
            [controller setMessageBody:body isHTML:YES];
            NSString *fileName = [NSString stringWithFormat:@"Peppermint.%@", extension];
            NSString *mimeType = [self typeForExtension:extension];
            [controller addAttachmentData:data mimeType:mimeType fileName:fileName];
        } complete:^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error) {
            if(error) {
                [controller dismissViewControllerAnimated:YES completion:nil];
                self.sendingStatus = SendingStatusError;
                [self.delegate operationFailure:error];
            } else if (result == MFMailComposeResultFailed) {
                [controller dismissViewControllerAnimated:YES completion:nil];
                error = [NSError errorWithDomain:LOC(@"An error occured",@"Unknown Error Message") code:0 userInfo:nil];
                self.sendingStatus = SendingStatusError;
                [self.delegate operationFailure:error];
            } else if (result == MFMailComposeResultSent) {
                [super sendVoiceMessageWithData:data withExtension:extension];
                self.sendingStatus = SendingStatusSent;
                [self.delegate messageStatusIsUpdated:SendingStatusSent withCancelOption:NO];
                [controller dismissViewControllerAnimated:NO completion:nil];
            } else {
                [controller dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        UIViewController *activeViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        self.sendingStatus = SendingStatusSending;
        [self.delegate messageStatusIsUpdated:SendingStatusSending withCancelOption:NO];
        [mailSender showFromViewController:activeViewController];
    } else {
        [self cacheMessage];
    }
}

-(BOOL) isServiceAvailable {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    return mailClass != nil && [MFMailComposeViewController canSendMail];
}

-(BOOL) needsAuth {
    return YES;
}

@end
