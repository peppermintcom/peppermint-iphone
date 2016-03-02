//
//  RecentContact+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 29/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "RecentContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecentContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *contactDate;

@end

NS_ASSUME_NONNULL_END
