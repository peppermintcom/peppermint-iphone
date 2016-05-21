//
//  PeppermintChatEntry.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "PeppermintChatEntry.h"
#import "Attribute.h"

@implementation PeppermintChatEntry {
    NSString *_contactEmail;
}

+(PeppermintChatEntry*) createFromAttribute:(Attribute*) attribute isIncomingMessage:(BOOL)isIncoming {
    
    PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
    peppermintChatEntry.audio = nil;
    peppermintChatEntry.audioUrl = attribute.audio_url;
    peppermintChatEntry.dateCreated = attribute.createdDate;
#warning "Get transcription from attribute"
    peppermintChatEntry.transcription = attribute.transcription;
    
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
    peppermintChatEntry.subject = @"";
    peppermintChatEntry.mailContent = @"";
    
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

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
    peppermintChatEntry.audio = self.audio.copy;
    peppermintChatEntry.audioUrl = self.audioUrl.copy;
    peppermintChatEntry.dateCreated = self.dateCreated.copy;
    peppermintChatEntry.contactEmail = self.contactEmail.copy;
    peppermintChatEntry.contactNameSurname = self.contactNameSurname.copy;
    peppermintChatEntry.duration = self.duration;
    peppermintChatEntry.isSeen = self.isSeen;
    peppermintChatEntry.isSentByMe = self.isSentByMe;
    peppermintChatEntry.messageId = self.messageId.copy;
    peppermintChatEntry.performedOperation = self.performedOperation;
    peppermintChatEntry.subject = self.subject;
    peppermintChatEntry.mailContent = self.mailContent;
    peppermintChatEntry.transcription = self.transcription.copy;
    return peppermintChatEntry;
}

#pragma mark - Contact Email Getter / Setter

-(void) setContactEmail:(NSString*)email {
    _contactEmail = email;
}

-(NSString*) contactEmail {
    return _contactEmail.lowercaseString;
}

#pragma mark - Is Audio Entry

-(ChatEntryType) type {
    ChatEntryType type = ChatEntryTypeNone;
    if(self.subject.length > 0 || self.mailContent.length > 0) {
        type = ChatEntryTypeEmail;
    } else if (self.duration > 0 || self.audio) {
        type = ChatEntryTypeAudio;
    }
    return type;
}

@end
