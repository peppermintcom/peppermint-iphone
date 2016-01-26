//
//  Chat+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Chat.h"
@class ChatEntry;

NS_ASSUME_NONNULL_BEGIN

@interface Chat (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *lastMessageDate;
@property (nullable, nonatomic, retain) NSNumber *unreadMessageCount;
@property (nullable, nonatomic, retain) NSSet<ChatEntry *> *chatEntries;

@end

@interface Chat (CoreDataGeneratedAccessors)

- (void)addChatEntriesObject:(ChatEntry *)value;
- (void)removeChatEntriesObject:(ChatEntry *)value;
- (void)addChatEntries:(NSSet<ChatEntry *> *)values;
- (void)removeChatEntries:(NSSet<ChatEntry *> *)values;

@end

NS_ASSUME_NONNULL_END
