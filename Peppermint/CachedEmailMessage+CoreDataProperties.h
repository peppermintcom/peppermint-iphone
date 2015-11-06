//
//  CachedEmailMessage+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 06/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CachedEmailMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface CachedEmailMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) NSString *extension;

@end

NS_ASSUME_NONNULL_END
