//
//  CachedMessage+CoreDataProperties.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CachedMessage+CoreDataProperties.h"

@implementation CachedMessage (CoreDataProperties)

@dynamic data;
@dynamic extension;
@dynamic mailSenderClass;
@dynamic receiverCommunicationChannelAddress;
@dynamic receiverNameSurname;
@dynamic senderEmail;
@dynamic senderNameSurname;
@dynamic receiverCommunicationChannel;

@end
