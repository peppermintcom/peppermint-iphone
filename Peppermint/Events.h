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

@interface RetrieveSignedUrlSuccessful : NSObject
@property (strong, nonatomic) NSString *signedUrl;
@end

@interface FileUploadCompleted : NSObject
@end

@interface FileUploadFinalized : NSObject
@property (strong, nonatomic) NSString *shortUrl;
@end