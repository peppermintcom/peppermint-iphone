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


+(PeppermintChatEntry*) createFromAttribute:(Attribute*) attribute forLoggedInAccountEmail:(NSString*)email {
    PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
    peppermintChatEntry.audio = nil;
    peppermintChatEntry.audioUrl = attribute.audio_url;
    peppermintChatEntry.dateCreated = attribute.createdDate;
    
    if([attribute.sender_email isEqualToString:attribute.recipient_email]
       || [attribute.recipient_email isEqualToString:email]) {
        peppermintChatEntry.contactEmail = attribute.sender_email;
        peppermintChatEntry.isSentByMe = NO;
        peppermintChatEntry.isSeen = attribute.read.length > 0;
    } else if([attribute.sender_email isEqualToString:email]) {
        peppermintChatEntry.contactEmail = attribute.recipient_email;
        peppermintChatEntry.isSentByMe = YES;
        peppermintChatEntry.isSeen = YES;
    }
    
    peppermintChatEntry.contactNameSurname = attribute.sender_name;
    peppermintChatEntry.duration = attribute.duration.integerValue;
    peppermintChatEntry.messageId = attribute.message_id;
    
    return peppermintChatEntry;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[PeppermintChatEntry class]]) {
        return NO;
    }
    PeppermintChatEntry * other = (PeppermintChatEntry *)object;
    return [other.audioUrl isEqualToString:self.audioUrl] || [other.messageId isEqualToString:self.messageId];
}

- (NSUInteger)hash {
    NSString *uniqueString = self.audioUrl ? self.audioUrl : self.messageId;
    NSUInteger hashValue = [uniqueString hash];
    return hashValue;
}

@end
