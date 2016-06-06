//
//  ContactSupportModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 23/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactSupportModel.h"
#import <MessageUI/MessageUI.h>
#import "EasyMailSender.h"
#import "DeviceModel.h"
#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"

@implementation ContactSupportModel

-(void) sendContactSupportMail {
    if(![self isMailServiceAvailable]) {
        [self showFeedbackAccountErrorAlert];
    } else {
        [self presentMailModalView];
    }
}

-(BOOL) isMailServiceAvailable {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    return mailClass != nil && [MFMailComposeViewController canSendMail];
}

-(void) showFeedbackAccountErrorAlert {
    NSString *title = LOC(@"Information", @"Information");
    NSString *message = LOC(@"Contact Support account error", @"Contact Support account error");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

-(void) presentMailModalView {
    __block NSString *body;
    EasyMailSender *mailSender = [EasyMailSender easyMail:^(MFMailComposeViewController *controller) {
        NSString *supportEmail = LOC(@"support@peppermint.com", @"Support Email");
        [controller setToRecipients:[NSArray arrayWithObject:supportEmail]];
        [controller setSubject:LOC(@"Contact Support Subject",@"Contact Support Subject")];
        body = [DeviceModel summary];
        [controller setMessageBody:body isHTML:YES];
    } complete:^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error) {
        if(error) {
            [controller dismissViewControllerAnimated:YES completion:nil];
            [self.delegate operationFailure:error];
        } else if (result == MFMailComposeResultFailed) {
            [controller dismissViewControllerAnimated:YES completion:nil];
            error = [NSError errorWithDomain:LOC(@"An error occured",@"Unknown Error Message") code:0 userInfo:nil];
            [self.delegate operationFailure:error];
        } else if (result == MFMailComposeResultSent) {
            [self.delegate contactSupportMailSentWithSuccess];
            [controller dismissViewControllerAnimated:NO completion:nil];
            NSMutableDictionary *messageDict = [NSMutableDictionary dictionaryWithDictionary:[DeviceModel summaryDictionary]];
            [messageDict setValue:body forKey:@"message"];
            [Answers logCustomEventWithName:@"ContactSupport" customAttributes:messageDict];
        } else {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    UIViewController *activeViewController = [[AppDelegate Instance] visibleViewController];
    [mailSender showFromViewController:activeViewController];
}

@end