//
//  ChatEntry+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatEntry (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *audio;
@property (nullable, nonatomic, retain) NSDate *dateCreated;
@property (nullable, nonatomic, retain) NSDate *dateListened;
@property (nullable, nonatomic, retain) NSDate *dateViewed;
@property (nullable, nonatomic, retain) NSNumber *isSentByMe;
@property (nullable, nonatomic, retain) NSString *transcription;
@property (nullable, nonatomic, retain) Chat *chat;

@end

NS_ASSUME_NONNULL_END
