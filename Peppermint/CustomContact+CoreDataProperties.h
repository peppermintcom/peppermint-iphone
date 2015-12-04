//
//  CustomContact+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 04/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CustomContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createDate;

@end

NS_ASSUME_NONNULL_END
