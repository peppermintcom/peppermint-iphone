//
//  PeppermintMessageSender.h
//  Peppermint
//
//  Created by Okan Kurtulus on 20/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

#define KEYCHAIN_MESSAGE_SENDER     @"keychainMessageSender"
#define KEYCHAIN_ACCESS_GROUP @"keychain.com.ppl.peppermint"

extern NSString *const AppConfigurationApplicationGroupsPrimary;

typedef enum : NSUInteger {
    LOGINSOURCE_FACEBOOK,
    LOGINSOURCE_GOOGLE,
    LOGINSOURCE_PEPPERMINT,
} LoginSource;

@interface PeppermintMessageSender : JSONModel
@property (strong, nonatomic) NSString *nameSurname;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString <Optional> * subject;

+ (instancetype) sharedInstance;

#if !(TARGET_OS_WATCH)
@property (strong, nonatomic) NSData<Ignore> *imageData;
@property (nonatomic) LoginSource loginSource;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString<Optional> *jwt;
@property (nonatomic) BOOL isEmailVerified;
@property (strong, nonatomic) NSString <Optional> * signature;

-(void) save;

-(BOOL) isValid;
-(NSString*) loginMethod;
-(void) clearSender;
-(BOOL) isInMailVerificationProcess;
#endif

@end