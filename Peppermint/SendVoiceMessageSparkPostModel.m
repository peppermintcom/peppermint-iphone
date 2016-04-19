//
//  SendVoiceMessageSparkPostModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageSparkPostModel.h"

@implementation SendVoiceMessageSparkPostModel {
    SparkPostService  *sparkPostService;
}

-(void) sendInterAppMessageIsCompletedWithError:(NSError*)error {
    [super sendInterAppMessageIsCompletedWithError:error];
    [self fireSparkPostMessageWithUrl:self.publicFileUrl canonicalUrl:self.canonicalUrl];
}


-(void) fireSparkPostMessageWithUrl:(NSString*) url canonicalUrl:(NSString*)canonicalUrl {
    NSString* nameSurname = @"";
    if(self.peppermintMessageSender.nameSurname.length > 0) {
        nameSurname = self.peppermintMessageSender.nameSurname;
        nameSurname = [nameSurname normalizeText];
    }
    NSString *email = @"";
    if(self.peppermintMessageSender.email.length > 0) {
        email = self.peppermintMessageSender.email;
        email = [email normalizeText];
    }
    
    NSString * subject = @"";
    if(self.subject) {
        subject = self.subject;
    } else if (self.peppermintMessageSender.subject.length > 0) {
        subject = self.peppermintMessageSender.subject;
    }
    
    SparkPostRequest *sparkPostMessage = [SparkPostRequest new];
    sparkPostMessage.campaign_id = @"iOS audio message";
    
    SparkPostRecipient *recipient = [SparkPostRecipient new];
    recipient.address = [self.selectedPeppermintContact.communicationChannelAddress normalizeText];
    [sparkPostMessage.recipients addObject:recipient];
    
    SparkPostContent *sparkPostContent = [SparkPostContent new];
    sparkPostContent.reply_to = email;
    sparkPostContent.from = [SparkPostFrom new];
    sparkPostContent.from.name = [NSString stringWithFormat:@"%@ [%@]", nameSurname, email];
    sparkPostContent.from.email = LOC(@"support@peppermint.com", @"Support Email");
    sparkPostContent.subject = subject;
    sparkPostMessage.content = sparkPostContent;
    
    SparkPostSubstitutionData *substitution_data = [SparkPostSubstitutionData new];
    substitution_data.canonical_url = canonicalUrl;
    substitution_data.url = url;
    substitution_data.replyLink = [self fastReplyUrlForSender];
    sparkPostMessage.substitution_data = substitution_data;
    
    if(![self isCancelled]) {
        self.sendingStatus = SendingStatusSendingWithNoCancelOption;
        sparkPostService = [SparkPostService new];
        [sparkPostService sendMessage:sparkPostMessage];
    }
}

SUBSCRIBE(MailClientMesssageSent) {
    if(event.sender == sparkPostService) {
        self.sendingStatus = SendingStatusSent;
    }
}

@end
