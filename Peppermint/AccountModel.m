//
//  AccountModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 14/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "AccountModel.h"
#import "AWSService.h"

@implementation AccountModel {
    AWSService *awsService;
    PeppermintMessageSender *cachedSender;
}

-(id) init {
    self = [super init];
    if(self) {
        awsService = [AWSService new];
    }
    return self;
}

-(void) authenticate:(PeppermintMessageSender*) peppermintMessageSender {
    cachedSender = peppermintMessageSender;
    User *user = [User new];
    user.full_name = cachedSender.nameSurname;
    user.email = cachedSender.email;
    user.password = cachedSender.password;
    [awsService registerAccount:user];
}

SUBSCRIBE(AccountRegisterIsSuccessful) {
    if([event.user.email isEqualToString:cachedSender.email]) {
        cachedSender.jwt = event.jwt;
        [self.delegate userRegisterSuccessWithEmail:cachedSender.email password:cachedSender.password jwt:cachedSender.jwt];
    }
}

SUBSCRIBE(AccountRegisterConflictTryLogin) {
    if([event.email isEqualToString:cachedSender.email]) {
        [self logUserIn:cachedSender.email password:cachedSender.password];
    }
}

-(void) logUserIn:(NSString*) email password:(NSString*) password {
    [awsService logUserInWithEmail:email password:password];
}

SUBSCRIBE(NetworkFailure) {
    NSError *error = event.error;
    NSDictionary *userInfo = error.userInfo;
    if([userInfo.allKeys containsObject:NSLocalizedDescriptionKey]) {
        NSString *errorText = [userInfo valueForKey:NSLocalizedDescriptionKey];
        errorText = [NSString stringWithFormat:@"TEST NOTE: Username/Password is incorrect!\n%@", errorText];
        error = [NSError errorWithDomain:errorText code:401 userInfo:nil];
    }
    [self.delegate operationFailure:error];
}

SUBSCRIBE(AccountLoginIsSuccessful) {
    if([event.user.email isEqualToString:cachedSender.email]) {
        [self.delegate userLogInSuccessWithEmail:cachedSender.email];
    }
}

#pragma mark - Email Verification Resend

-(void) resendVerificationEmail:(PeppermintMessageSender*) peppermintMessageSender {
    cachedSender = peppermintMessageSender;
    [awsService resendVerificationEmailForJwt:cachedSender.jwt];
}

SUBSCRIBE(VerificationEmailSent) {
    if([event.jwt isEqualToString:cachedSender.jwt]) {
        [self.delegate verificationEmailSendSuccess];
    }
}

@end
