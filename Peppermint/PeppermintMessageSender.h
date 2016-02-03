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

typedef enum : NSUInteger {
    LOGINSOURCE_FACEBOOK,
    LOGINSOURCE_GOOGLE,
    LOGINSOURCE_PEPPERMINT,
    LOGINSOURCE_WITHOUTLOGIN,
} LoginSource;

@interface PeppermintMessageSender : JSONModel
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *surname;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSData<Ignore> *imageData;
@property (nonatomic) LoginSource loginSource;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString<Optional> *jwt;
@property (nonatomic) BOOL isEmailVerified;
@property (strong, nonatomic) NSString <Optional> * signature;
@property (strong, nonatomic) NSString <Optional> * subject;
@property (strong, nonatomic) NSString <Optional> * accountId;
@property (strong, nonatomic) NSString <Optional> * recorderJwt;
@property (strong, nonatomic) NSString <Optional> * recorderId;
@property (strong, nonatomic) NSString <Optional> * recorderClientId;
@property (strong, nonatomic) NSString <Optional> * recorderKey;
@property (atomic) BOOL isAccountSetUpWithRecorder;

@property (strong, nonatomic) NSString <Optional> * exchangedJwt;

+ (instancetype) sharedInstance;
-(void) save;
-(BOOL) isValidToUseApp;
-(BOOL) isValidToSendMessage;
-(NSString*) loginMethod;
-(void) clearSender;
-(BOOL) isInMailVerificationProcess;
-(void) verifyEmail;

-(NSString*) nameSurname;
-(void) setNameSurname:(NSString*)nameSurname;

@end