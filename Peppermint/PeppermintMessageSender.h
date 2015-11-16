//
//  PeppermintMessageSender.h
//  Peppermint
//
//  Created by Okan Kurtulus on 20/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

typedef enum : NSUInteger {
    LOGINSOURCE_FACEBOOK,
    LOGINSOURCE_GOOGLE,
    LOGINSOURCE_PEPPERMINT,
} LoginSource;

@interface PeppermintMessageSender : JSONModel
@property (strong, nonatomic) NSString *nameSurname;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSData<Ignore> *imageData;
@property (nonatomic) LoginSource loginSource;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString<Optional> *jwt;
@property (nonatomic) BOOL isEmailVerified;

+ (instancetype) sharedInstance;
-(void) save;
-(BOOL) isValid;
-(NSString*) loginMethod;
-(void) clearSender;
-(BOOL) isInMailVerificationProcess;

@end