//
//  PeppermintChatEntry.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "PeppermintChatEntry.h"
#import "Attribute.h"

@implementation PeppermintChatEntry


+(PeppermintChatEntry*) createFromAttribute:(Attribute*) attribute {
    PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
    peppermintChatEntry.audio = nil;
    peppermintChatEntry.audioUrl = attribute.audio_url;
    peppermintChatEntry.dateCreated = attribute.createdDate;
    peppermintChatEntry.contactEmail = attribute.sender_email;
    peppermintChatEntry.contactNameSurname = attribute.sender_name;
    peppermintChatEntry.duration = attribute.duration.integerValue;
    peppermintChatEntry.isSentByMe = NO;
    peppermintChatEntry.messageId = attribute.message_id;
    peppermintChatEntry.isSeen = attribute.read.length > 0;
    return peppermintChatEntry;
}

@end
