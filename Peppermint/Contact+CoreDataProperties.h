//
//  Contact+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 04/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *avatarImageData;
@property (nullable, nonatomic, retain) NSNumber *communicationChannel;
@property (nullable, nonatomic, retain) NSString *communicationChannelAddress;
@property (nullable, nonatomic, retain) NSString *nameSurname;

@end

NS_ASSUME_NONNULL_END
