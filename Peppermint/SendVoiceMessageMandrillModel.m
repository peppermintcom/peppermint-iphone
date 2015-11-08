//
//  SendVoiceMessageMandrillModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "SendVoiceMessageMandrillModel.h"

@implementation SendVoiceMessageMandrillModel {
    MandrillMessage *mandrillMessage;
    NSData *_data;
    NSString *_extension;
}

-(void) sendVoiceMessageWithData:(NSData *)data withExtension:(NSString *)extension  {
    [super sendVoiceMessageWithData:data withExtension:extension];
    
#warning "Try nicer method to delay dealloc ing model objects when processing a message"
    if(![AppDelegate Instance].mutableArray) {
        [AppDelegate Instance].mutableArray = [NSMutableArray new];
    }
    
    if([self isConnectionActive]) {
        [[AppDelegate Instance].mutableArray addObject:self];
        _data = data;
        _extension = extension;
        self.sendingStatus = SendingStatusUploading;
        [self.delegate messageStatusIsUpdated:SendingStatusUploading withCancelOption:YES];
        [awsModel startToUploadData:data ofType:[self typeForExtension:extension]];
        if(self.delegate != nil) {
            [[CacheModel sharedInstance] triggerCachedMessages];
        }
    } else {
        [[CacheModel sharedInstance] cache:self WithData:data extension:extension];
    }
}

#pragma mark - AWSModelDelegate

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    NSLog(@"File Upload is finished with url %@", url);
    if(![self isCancelled]) {
        self.sendingStatus = SendingStatusSending;
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
    
    mandrillMessage = [MandrillMessage new];
    mandrillMessage.from_email = self.peppermintMessageSender.email;
    
    mandrillMessage.from_name = nameSurname;
    mandrillMessage.subject = LOC(@"Mail Subject",@"Default Mail Subject");
    NSString *body = [NSString stringWithFormat:LOC(@"Mail Body Format",@"Default Mail Body Format"), url, [self fastReplyUrlForSender]];
    mandrillMessage.html = body;
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
        self.sendingStatus = SendingStatusSending;
        [self.delegate messageStatusIsUpdated:SendingStatusSending withCancelOption:NO];
        [[MandrillService new] sendMessage:mandrillMessage];
    } else {
        self.sendingStatus = SendingStatusCancelled;
    }
    [[AppDelegate Instance].mutableArray removeObject:self];
}

SUBSCRIBE(MandrillMesssageSent) {
    if([event.mandrillMessage isEqual:mandrillMessage]) {
        self.sendingStatus = SendingStatusSent;
        [self.delegate messageStatusIsUpdated:SendingStatusSent withCancelOption:NO];
    }
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