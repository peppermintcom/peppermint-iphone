//
//  RecentContact.h
//  Peppermint
//
//  Created by Okan Kurtulus on 10/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecentContact : NSManagedObject

@property (nonatomic, retain) NSDate * contactDate;
@property (nonatomic, retain) NSData * avatarImageData;
@property (nonatomic, retain) NSString * nameSurname;
@property (nonatomic, retain) NSString * communicationChannelAddress;
@property (nonatomic, retain) NSNumber * communicationChannel;

@end
