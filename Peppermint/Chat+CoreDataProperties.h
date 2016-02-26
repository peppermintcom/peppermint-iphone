//
//  Chat+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Chat.h"

NS_ASSUME_NONNULL_BEGIN

@interface Chat (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *lastMessageDate;

@end

NS_ASSUME_NONNULL_END
