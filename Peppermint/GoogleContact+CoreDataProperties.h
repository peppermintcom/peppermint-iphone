//
//  GoogleContact+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GoogleContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoogleContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accountEmail;

@end

NS_ASSUME_NONNULL_END
