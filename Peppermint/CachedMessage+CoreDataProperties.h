//
//  CachedMessage+CoreDataProperties.h
//  Peppermint
//
//  Created by Okan Kurtulus on 09/06/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CachedMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface CachedMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSString *extension;
@property (nullable, nonatomic, retain) NSString *mailSenderClass;
@property (nullable, nonatomic, retain) NSData *rawAudioData;
@property (nullable, nonatomic, retain) NSNumber *receiverCommunicationChannel;
@property (nullable, nonatomic, retain) NSString *receiverCommunicationChannelAddress;
@property (nullable, nonatomic, retain) NSString *receiverNameSurname;
@property (nullable, nonatomic, retain) NSString *senderEmail;
@property (nullable, nonatomic, retain) NSString *senderNameSurname;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *transcriptionText;
@property (nullable, nonatomic, retain) NSNumber *retryCount;

@end

NS_ASSUME_NONNULL_END
