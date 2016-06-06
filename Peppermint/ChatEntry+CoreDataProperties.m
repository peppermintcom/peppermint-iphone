//
//  ChatEntry+CoreDataProperties.m
//  Peppermint
//
//  Created by Okan Kurtulus on 06/06/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatEntry+CoreDataProperties.h"

@implementation ChatEntry (CoreDataProperties)

@dynamic audio;
@dynamic audioUrl;
@dynamic contactEmail;
@dynamic dateCreated;
@dynamic duration;
@dynamic isForwarded;
@dynamic isRepliedAnswered;
@dynamic isSeen;
@dynamic isSentByMe;
@dynamic isStarredFlagged;
@dynamic mailContent;
@dynamic messageId;
@dynamic subject;
@dynamic transcription;

@end
