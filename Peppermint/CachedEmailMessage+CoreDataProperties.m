//
//  CachedEmailMessage+CoreDataProperties.m
//  Peppermint
//
//  Created by Okan Kurtulus on 06/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CachedEmailMessage+CoreDataProperties.h"

@implementation CachedEmailMessage (CoreDataProperties)

@dynamic data;
@dynamic extension;
@dynamic senderNameSurname;
@dynamic senderEmail;
@dynamic receiverNameSurname;
@dynamic receiverEmail;
@dynamic mailSenderClass;

@end
