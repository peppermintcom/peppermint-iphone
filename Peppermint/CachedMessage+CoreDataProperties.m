//
//  CachedMessage+CoreDataProperties.m
//  Peppermint
//
//  Created by Okan Kurtulus on 07/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CachedMessage+CoreDataProperties.h"

@implementation CachedMessage (CoreDataProperties)

@dynamic data;
@dynamic duration;
@dynamic extension;
@dynamic mailSenderClass;
@dynamic receiverCommunicationChannel;
@dynamic receiverCommunicationChannelAddress;
@dynamic receiverNameSurname;
@dynamic senderEmail;
@dynamic senderNameSurname;
@dynamic subject;

@end
