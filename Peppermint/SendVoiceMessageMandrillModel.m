//
//  SendVoiceMessageMandrillModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageMandrillModel.h"

@implementation SendVoiceMessageMandrillModel {
    MandrillService *mandrillService;
    MandrillMessage *mandrillMessage;
}

-(void) sendVoiceMessageWithData:(NSData *)data withExtension:(NSString *)extension andDuration:(NSTimeInterval)duration {
    
    [super sendVoiceMessageWithData:data withExtension:extension andDuration:duration];
    if([self isConnectionActive]) {
        _data = data;
        _extension = extension;
        _duration = duration;
        self.sendingStatus = SendingStatusUploading;
        [awsModel startToUploadData:data ofType:[self typeForExtension:extension]];
    } else {
        [self cacheMessage];
    }
}

#pragma mark - AWSModelDelegate

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    [super fileUploadCompletedWithPublicUrl:url];
    if(![self isCancelled]) {
        self.sendingStatus = SendingStatusSending;
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
  
    NSString * signature = @"";
  
  if (self.peppermintMessageSender.signature.length > 0) {
    signature = self.peppermintMessageSender.signature;
  }
  
  NSString * subject = @"";
  
  if (self.peppermintMessageSender.subject.length > 0) {
    subject = self.peppermintMessageSender.subject;
  }
    
    mandrillMessage = [MandrillMessage new];
    mandrillMessage.from_email = @"support@peppermint.com"; //self.peppermintMessageSender.email;
    
    mandrillMessage.from_name =
    [NSString stringWithFormat:@"%@ <%@>", nameSurname, self.peppermintMessageSender.email];
    
    mandrillMessage.subject = subject;
    
    //NSString *body = [self mailBodyHTMLForUrlPath:url extension:_extension signature:signature duration:_duration];
    mandrillMessage.html = nil;
    mandrillMessage.global_merge_vars = [self mandrillNameContentPairForUrlPath:url extension:_extension signature:signature duration:_duration];
    
    NSString *textBody = [NSString stringWithFormat:LOC(@"Mail Text Format",@"Default Mail Text Format"), url, [self fastReplyUrlForSender], signature];
    mandrillMessage.text = textBody;
    
    MandrillToObject *recipient = [MandrillToObject new];
    recipient.email = self.selectedPeppermintContact.communicationChannelAddress;
    recipient.name = self.selectedPeppermintContact.nameSurname;
    recipient.type = TYPE_TO;
    [mandrillMessage.to addObject:recipient];
    
    [mandrillMessage.tags addObject:@"Peppermint iOS"];
    
    MandrillMailAttachment *mailAttachment = [MandrillMailAttachment new];
    mailAttachment.type = [self typeForExtension:_extension];
    mailAttachment.name = [NSString stringWithFormat:@"Peppermint.%@", _extension];
    mailAttachment.content = [_data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [mandrillMessage.attachments addObject:mailAttachment];
    
    [mandrillMessage.headers setObject:email forKey:@"Reply-To"];
    
    if(![self isCancelled]) {
        self.sendingStatus = SendingStatusSendingWithNoCancelOption;
        mandrillService = [MandrillService new];
        NSString* templateName = @"ios-voice-message";
        [mandrillService sendMessage:mandrillMessage templateName:templateName];
    }
}

SUBSCRIBE(MandrillMesssageSent) {
    if(event.sender == mandrillService) {
        self.sendingStatus = SendingStatusSent;
    }
}

-(BOOL) needsAuth {
    return YES;
}

-(void) cancelSending {
    _data = nil;
    _extension = nil;
    _duration = 0;
    [super cancelSending];
}

-(BOOL) isCancelAble {
    BOOL result = NO;
    switch (self.sendingStatus) {
        case SendingStatusIniting:
        case SendingStatusInited:
        case SendingStatusStarting:
        case SendingStatusUploading:
        case SendingStatusSending:
            result = YES;
            break;
        case SendingStatusError:
        case SendingStatusCancelled:
        case SendingStatusCached:
        case SendingStatusSendingWithNoCancelOption:
        case SendingStatusSent:
            result = NO;
            break;
        default:
            break;
    }
    return result;
}

-(NSMutableArray<MandrillNameContentPair>*) mandrillNameContentPairForUrlPath:(NSString*)urlPath extension:(NSString*)extension signature:(NSString*) signature duration:(NSTimeInterval) duration {
    
    int minutes = duration / 60;
    int seconds = (int)duration % 60;
    
    int minutesDigit1 = minutes / 10;
    int minutesDigit2 = minutes % 10;
    int secondsDigit1 = seconds / 10;
    int secondsDigit2 = seconds % 10;
    NSString *replyLink = [self fastReplyUrlForSender];
    
    NSMutableArray<MandrillNameContentPair> *contentMutableArray = [NSMutableArray<MandrillNameContentPair> new];
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"url" content:urlPath]];
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"replyLink" content:replyLink]];
    
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"minutesDigit1" content:[NSString stringWithFormat:@"%d", minutesDigit1]]];
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"minutesDigit2" content:[NSString stringWithFormat:@"%d", minutesDigit2]]];
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"secondsDigit1" content:[NSString stringWithFormat:@"%d", secondsDigit1]]];
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"secondsDigit2" content:[NSString stringWithFormat:@"%d", secondsDigit2]]];
    
    return contentMutableArray;
}

@end