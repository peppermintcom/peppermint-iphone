//
//  RecentContact+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 28/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "RecentContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecentContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *peppermintContactDate;
@property (nullable, nonatomic, retain) NSDate *mailClientContactDate;

@end

NS_ASSUME_NONNULL_END
