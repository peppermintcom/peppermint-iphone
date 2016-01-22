//
//  ChatEntry+CoreDataProperties.m
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatEntry+CoreDataProperties.h"

@implementation ChatEntry (CoreDataProperties)

@dynamic audio;
@dynamic dateCreated;
@dynamic dateListened;
@dynamic dateViewed;
@dynamic isSentByMe;
@dynamic transcription;
@dynamic chat;

@end
