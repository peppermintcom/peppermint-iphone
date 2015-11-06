//
//  Events.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MandrillMessage.h"

@interface NetworkFailure : NSObject
@property(nonatomic) NSError *error;
@end

//locked
@interface MandrillMesssageSent : NSObject
@property (strong, nonatomic) MandrillMessage *mandrillMessage;
@end

@interface ApplicationWillResignActive : NSObject
@end

@interface ApplicationDidEnterBackground : NSObject
@end

@interface ApplicationWillEnterForeground : NSObject
@end

@interface ApplicationDidBecomeActive : NSObject
@end

@interface RecorderSubmitSuccessful : NSObject
@property (strong, nonatomic) NSString *jwt;
@end

//locked
@interface RetrieveSignedUrlSuccessful : NSObject
@property (strong, nonatomic) NSString *signedUrl;
@property (strong, nonatomic) NSData* data;
@end

//locked
@interface FileUploadCompleted : NSObject
@property (strong, nonatomic) NSString *signedUrl;
@end

//locked
@interface FileUploadFinalized : NSObject
@property (strong, nonatomic) NSString *signedUrl;
@property (strong, nonatomic) NSString *shortUrl;
@end