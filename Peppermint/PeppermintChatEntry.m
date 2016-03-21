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


+(PeppermintChatEntry*) createFromAttribute:(Attribute*) attribute isIncomingMessage:(BOOL)isIncoming {
    
    PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
    peppermintChatEntry.audio = nil;
    peppermintChatEntry.audioUrl = attribute.audio_url;
    peppermintChatEntry.dateCreated = attribute.createdDate;
    
    if(isIncoming) {
        peppermintChatEntry.contactNameSurname = attribute.sender_name;
        peppermintChatEntry.contactEmail = attribute.sender_email;
        peppermintChatEntry.isSentByMe = NO;
        peppermintChatEntry.isSeen = attribute.read.length > 0;
    } else {
        peppermintChatEntry.contactNameSurname = attribute.recipient_email;
        peppermintChatEntry.contactEmail = attribute.recipient_email;
        peppermintChatEntry.isSentByMe = YES;
        peppermintChatEntry.isSeen = YES;
    }
    
    peppermintChatEntry.duration = attribute.duration.integerValue;
    peppermintChatEntry.messageId = attribute.message_id;
    
    return peppermintChatEntry;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[PeppermintChatEntry class]]) {
        return NO;
    }
    PeppermintChatEntry * other = (PeppermintChatEntry *)object;
    BOOL isSentByMeMatches = self.isSentByMe == other.isSentByMe;
    BOOL doesMessageIdsMatch = !self.messageId || !other.messageId || [other.messageId isEqualToString:self.messageId];
    BOOL isAudioUrlMatches = self.audioUrl.length == 0 || other.audioUrl.length == 0 || [self.audioUrl isEqualToString:other.audioUrl];
    BOOL isAudioMatches = !self.audio || !other.audio || self.audio == other.audio;
    return isSentByMeMatches && doesMessageIdsMatch && isAudioUrlMatches && isAudioMatches;
}

- (NSUInteger)hash {
    NSString *uniqueString = [NSString stringWithFormat:@"%@%d", self.audioUrl, self.isSentByMe];
    NSUInteger hashValue = [uniqueString hash];
    return hashValue;
}

@end
