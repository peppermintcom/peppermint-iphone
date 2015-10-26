//
//  SendVoiceMessageMandrillModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageMandrillModel.h"

@implementation SendVoiceMessageMandrillModel

-(void) sendVoiceMessageWithData:(NSData *)data withExtension:(NSString *)extension  {
    [super sendVoiceMessageWithData:data withExtension:extension];
    [self.delegate messageIsSendingWithCancelOption:YES];
    [awsModel startToUploadData:data ofType:[self typeForExtension:extension]];
}

#pragma mark - AWSModelDelegate

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    NSLog(@"File Upload is finished with url %@", url);
    if(!self.isCancelled) {
        [self fireMandrillMessageWithUrl:url];
    } else {
        NSLog(@"Mandrill message sending is not fired, cos message is cancelled");
    }
}

-(void) fireMandrillMessageWithUrl:(NSString*) url {

    MandrillMessage *message = [MandrillMessage new];
    message.from_email = @"noreply@peppermint.com";
    message.from_name = self.peppermintMessageSender.nameSurname;
    message.subject = LOC(@"Mail Subject",@"Default Mail Subject");
    message.html = LOC(@"Mail Body",@"Default Mail Body");
    
    message.html = [NSString stringWithFormat:@"%@ \n\n<a href=\"%@\">Message, (TEST: Attachment is removed cos there is a link now. It can be added again too. decision will be given for this behaviour)</a>", message.html,
                    url];
    
    MandrillToObject *recipient = [MandrillToObject new];
    recipient.email = self.selectedPeppermintContact.communicationChannelAddress;
    recipient.name = self.selectedPeppermintContact.nameSurname;
    recipient.type = TYPE_TO;
    [message.to addObject:recipient];
    [message.tags addObject:@"Peppermint iOS"];
    
    /*
    MandrillMailAttachment *mailAttachment = [MandrillMailAttachment new];
    mailAttachment.type = [self typeForExtension:extension];
    mailAttachment.name = [NSString stringWithFormat:@"Peppermint.%@", extension];
    mailAttachment.content = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [message.attachments addObject:mailAttachment];
    */
    [message.headers setObject:self.peppermintMessageSender.email forKey:@"Reply-To"];
    [self.delegate messageIsSendingWithCancelOption:NO];
    [[MandrillService new] sendMessage:message];
}

SUBSCRIBE(MandrillMesssageSent) {
    [self.delegate messageSentWithSuccess];
}

@end
