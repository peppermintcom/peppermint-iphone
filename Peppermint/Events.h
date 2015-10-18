//
//  Events.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkFailure : NSObject
@property(nonatomic) NSError *error;
@end

@interface MandrillMesssageSent : NSObject
@end