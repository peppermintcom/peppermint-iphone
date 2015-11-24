//
//  Events.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MandrillMessage.h"
#import "User.h"

@interface NetworkFailure : NSObject
@property (nonatomic) id sender;
@property(nonatomic) NSError *error;
@end

//Needs a unique handler
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

//Needs a unique handler
@interface RetrieveSignedUrlSuccessful : NSObject
@property (strong, nonatomic) NSString *signedUrl;
@property (strong, nonatomic) NSData* data;
@end

//Needs a unique handler
@interface FileUploadCompleted : NSObject
@property (strong, nonatomic) NSString *signedUrl;
@end

//Needs a unique handler
@interface FileUploadFinalized : NSObject
@property (strong, nonatomic) NSString *signedUrl;
@property (strong, nonatomic) NSString *shortUrl;
@end

@interface AccountRegisterIsSuccessful : NSObject
@property (strong, nonatomic) NSString *jwt;
@property (strong, nonatomic) User *user;
@end

@interface AccountLoginIsSuccessful : NSObject
@property (strong, nonatomic) User *user;
@end

@interface AccountRegisterConflictTryLogin : NSObject
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@end

@interface VerificationEmailSent : NSObject
@property (strong, nonatomic) NSString* jwt;
@end

@interface AccountInfoRefreshed : NSObject
@property (strong, nonatomic) User *user;
@end

@interface RetrieveGoogleContactsIsSuccessful : NSObject
@property (nonatomic) BOOL hasNext;
@end
