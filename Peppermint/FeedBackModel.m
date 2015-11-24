//
//  FeedBackModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "FeedBackModel.h"
#import <MessageUI/MessageUI.h>
#import "EasyMailSender.h"
#import "EasyMailAlertSender.h"
#import "DeviceModel.h"
#import <Crashlytics/Crashlytics.h>


@implementation FeedBackModel

-(void) sendFeedBackMail {
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
    NSString *message = LOC(@"Feedback account error", @"Feedback account error");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

-(void) presentMailModalView {
    __block NSString *body;
    EasyMailAlertSender *mailSender = [EasyMailAlertSender easyMail:^(MFMailComposeViewController *controller) {
        NSString *supportEmail = LOC(@"support@peppermint.com", @"Support Email");
        [controller setToRecipients:[NSArray arrayWithObject:supportEmail]];
        [controller setSubject:LOC(@"Feedback Subject",@"Feedback Subject")];
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
            [self.delegate feedBackSentWithSuccess];
            [controller dismissViewControllerAnimated:NO completion:nil];
            NSMutableDictionary *messageDict = [NSMutableDictionary dictionaryWithDictionary:[DeviceModel summaryDictionary]];
            [messageDict setValue:body forKey:@"message"];
            [Answers logCustomEventWithName:@"Feedback" customAttributes:messageDict];
        } else {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    UIViewController *activeViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [mailSender showFromViewController:activeViewController];
}


@end