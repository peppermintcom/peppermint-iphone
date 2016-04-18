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

-(void) sendInterAppMessageIsCompletedWithError:(NSError*)error {
    [super sendInterAppMessageIsCompletedWithError:error];
    [self fireMandrillMessageWithUrl:self.publicFileUrl canonicalUrl:self.canonicalUrl];
}

-(void) fireMandrillMessageWithUrl:(NSString*) url canonicalUrl:(NSString*)canonicalUrl {
    
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
  
    NSString * signature = @"";
    if (self.peppermintMessageSender.signature.length > 0) {
        signature = self.peppermintMessageSender.signature;
    }
  
    NSString * subject = @"";
    if(self.subject) {
        subject = self.subject;
    } else if (self.peppermintMessageSender.subject.length > 0) {
        subject = self.peppermintMessageSender.subject;
    }
    
    mandrillMessage = [MandrillMessage new];
    mandrillMessage.from_email = LOC(@"support@peppermint.com", @"Support Email"); //self.peppermintMessageSender.email;
    
    NSString *fromName = [NSString stringWithFormat:@"%@ [%@]", nameSurname, email];
    mandrillMessage.from_name = fromName;
    mandrillMessage.subject = subject;
    
    mandrillMessage.html = nil;
    mandrillMessage.text = nil; // HTML and text is set from template!
    mandrillMessage.global_merge_vars = [self mandrillNameContentPairForUrlPath:url extension:_extension signature:signature duration:_duration canonicalUrl:canonicalUrl];
    
    MandrillToObject *recipient = [MandrillToObject new];
    recipient.email = [self.selectedPeppermintContact.communicationChannelAddress normalizeText];
    recipient.name = [self.selectedPeppermintContact.nameSurname normalizeText];
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

SUBSCRIBE(MailClientMesssageSent) {
    if(event.sender == mandrillService) {
        self.sendingStatus = SendingStatusSent;
    }
}

-(NSMutableArray<MandrillNameContentPair>*) mandrillNameContentPairForUrlPath:(NSString*)urlPath extension:(NSString*)extension signature:(NSString*) signature duration:(NSTimeInterval) duration canonicalUrl:(NSString*)canonicalUrl{
    
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
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"canonicalUrl" content:canonicalUrl]];
    
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"minutesDigit1" content:[NSString stringWithFormat:@"%d", minutesDigit1]]];
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"minutesDigit2" content:[NSString stringWithFormat:@"%d", minutesDigit2]]];
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"secondsDigit1" content:[NSString stringWithFormat:@"%d", secondsDigit1]]];
    [contentMutableArray addObject:[MandrillNameContentPair createWithName:@"secondsDigit2" content:[NSString stringWithFormat:@"%d", secondsDigit2]]];
    return contentMutableArray;
}

@end