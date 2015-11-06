//
//  SendVoiceMessageMandrillModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageMandrillModel.h"

@implementation SendVoiceMessageMandrillModel {
    NSData *_data;
    NSString *_extension;
}

-(void) sendVoiceMessageWithData:(NSData *)data withExtension:(NSString *)extension  {
    [super sendVoiceMessageWithData:data withExtension:extension];
    _data = data;
    _extension = extension;
    [self.delegate messageStatusIsUpdated:SendingStatusUploading withCancelOption:YES];
    [awsModel startToUploadData:data ofType:[self typeForExtension:extension]];
}

#pragma mark - AWSModelDelegate

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    NSLog(@"File Upload is finished with url %@", url);
    if(!isCancelled) {
        [self.delegate messageStatusIsUpdated:SendingStatusSending withCancelOption:YES];
        [self fireMandrillMessageWithUrl:url];
    } else {
        NSLog(@"Mandrill message sending is not fired, cos message is cancelled");
    }
}

-(void) fireMandrillMessageWithUrl:(NSString*) url {

    
    NSString* nameSurname = @"";
    if(self.peppermintMessageSender.nameSurname.length > 0) {
        nameSurname = self.peppermintMessageSender.nameSurname;
    }
    NSString *email = @"";
    if(self.peppermintMessageSender.email.length > 0) {
        email = self.peppermintMessageSender.email;
    }
    
    MandrillMessage *message = [MandrillMessage new];
    message.from_email = self.peppermintMessageSender.email;
    message.from_name = nameSurname;
    message.subject = LOC(@"Mail Subject",@"Default Mail Subject");
    NSString *body = [NSString stringWithFormat:LOC(@"Mail Body Format",@"Default Mail Body Format"), url, [self fastReplyUrlForSender]];
    message.html = body;
    MandrillToObject *recipient = [MandrillToObject new];
    recipient.email = self.selectedPeppermintContact.communicationChannelAddress;
    recipient.name = self.selectedPeppermintContact.nameSurname;
    recipient.type = TYPE_TO;
    [message.to addObject:recipient];
    [message.tags addObject:@"Peppermint iOS"];
    
    
    MandrillMailAttachment *mailAttachment = [MandrillMailAttachment new];
    mailAttachment.type = [self typeForExtension:_extension];
    mailAttachment.name = [NSString stringWithFormat:@"Peppermint.%@", _extension];
    mailAttachment.content = [_data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [message.attachments addObject:mailAttachment];
    
    [message.headers setObject:email forKey:@"Reply-To"];
    
    if(!isCancelled) {
        [self.delegate messageStatusIsUpdated:SendingStatusSending withCancelOption:NO];
        [[MandrillService new] sendMessage:message];
    }
}

SUBSCRIBE(MandrillMesssageSent) {
    [self.delegate messageStatusIsUpdated:SendingStatusSent withCancelOption:NO];
}

-(BOOL) needsAuth {
    return YES;
}

-(void) cancelSending {
    _data = nil;
    _extension = nil;
    [super cancelSending];
}

@end