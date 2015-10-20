//
//  SendVoiceMessageMandrillModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageMandrillModel.h"

@implementation SendVoiceMessageMandrillModel

-(void) sendVoiceMessageWithData:(NSData*) data {    
    [super sendVoiceMessageWithData:data];    
    MandrillMessage *message = [MandrillMessage new];
    message.from_email = @"noreply@peppermint.com";
    message.from_name = self.peppermintMessageSender.nameSurname;
    message.subject = LOC(@"Mail Subject",@"Default Mail Subject");
    message.html = LOC(@"Mail Body",@"Default Mail Body");
    MandrillToObject *recipient = [MandrillToObject new];
    recipient.email = self.selectedPeppermintContact.communicationChannelAddress;
    recipient.name = self.selectedPeppermintContact.nameSurname;
    recipient.type = TYPE_TO;
    [message.to addObject:recipient];
    [message.tags addObject:@"Peppermint iOS"];
    MandrillMailAttachment *mailAttachment = [MandrillMailAttachment new];
    mailAttachment.type = TYPE_M4A;
    mailAttachment.name = @"Peppermint.m4a";
    mailAttachment.content = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [message.attachments addObject:mailAttachment];
    [message.headers setObject:self.peppermintMessageSender.email forKey:@"Reply-To"];
    [self.delegate messageIsSending];
    
    [[MandrillService new] sendMessage:message];
}

SUBSCRIBE(MandrillMesssageSent) {
    [self.delegate messageSentWithSuccess];
}

SUBSCRIBE(NetworkFailure) {
    [self.delegate operationFailure:[event error]];
}

@end
