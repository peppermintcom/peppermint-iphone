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

+ (instancetype) sharedInstance {
    return SHARED_INSTANCE( [[self alloc] initShared] );
}

-(id) init {
    NSAssert(false, @"This model instance is singleton so should not be inited - %@", self);
    return nil;
}

-(id) initShared {
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
    if([event.user.email caseInsensitiveCompare:cachedSender.email] == NSOrderedSame) {
        cachedSender.jwt = event.jwt;
        cachedSender.accountId = event.user.account_id;
        [self.delegate userRegisterSuccessWithEmail:cachedSender.email password:cachedSender.password jwt:cachedSender.jwt];
    }
}

SUBSCRIBE(AccountRegisterConflictTryLogin) {
    if([event.email caseInsensitiveCompare:cachedSender.email] == NSOrderedSame) {
        [self logUserIn:cachedSender.email password:cachedSender.password];
    }
}

-(void) logUserIn:(NSString*) email password:(NSString*) password {
    if(!cachedSender) {
        cachedSender = [PeppermintMessageSender sharedInstance];
    }
    [awsService logUserInWithEmail:email password:password];
}

SUBSCRIBE(NetworkFailure) {
    if(event.sender == awsService) {
        NSError *error = event.error;
        [self.delegate operationFailure:error];
    }
}

SUBSCRIBE(AccountLoginIsSuccessful) {
    if([event.user.email caseInsensitiveCompare:cachedSender.email] == NSOrderedSame) {
        cachedSender.nameSurname = event.user.full_name;
        cachedSender.accountId = event.user.account_id;
        cachedSender.jwt = event.jwt;
        cachedSender.isEmailVerified = event.user.is_verified.boolValue;
        [[PeppermintMessageSender sharedInstance] save];
        [self.delegate userLogInSuccessWithEmail:cachedSender.email];
    }
}

#pragma mark - Email Verification Resend

-(void) resendVerificationEmail:(PeppermintMessageSender*) peppermintMessageSender {
    cachedSender = peppermintMessageSender;
    [awsService resendVerificationEmailForJwt:cachedSender.jwt];
}

SUBSCRIBE(VerificationEmailSent) {    
    if(event.sender == awsService && [event.jwt isEqualToString:cachedSender.jwt]) {
        if([self.delegate respondsToSelector:@selector(verificationEmailSendSuccess)]) {
            [self.delegate verificationEmailSendSuccess];
        }
    }
}

- (void)checkEmailIsRegistered:(NSString *)email {
  [awsService checkEmailIsRegistered:email];
}

SUBSCRIBE(AccountCheckEmail) {
    if([self.delegate respondsToSelector:@selector(checkEmailIsRegisteredIsSuccess:isEmailVerified:)]) {
        [self.delegate checkEmailIsRegisteredIsSuccess:event.isEmailRegistered isEmailVerified:event.isEmailVerified];
    } else {
        NSLog(@"Please implement checkEmailIsRegisteredIsSuccess:isEmailVerified: to get response isEmailRegistered %d, isEmailVerified %d", event.isEmailRegistered, event.isEmailVerified);
    }
}

#pragma mark - Refresh Account

-(void)refreshAccountInfo:(PeppermintMessageSender*) peppermintMessageSender {
    cachedSender = peppermintMessageSender;
    [awsService refreshAccountWithId:cachedSender.accountId andJwt:cachedSender.jwt];
}

SUBSCRIBE(AccountInfoRefreshed) {
    if([event.user.account_id isEqualToString:cachedSender.accountId]) {
        cachedSender.isEmailVerified = event.user.is_verified.boolValue;
        [cachedSender save];
        [self.delegate accountInfoRefreshSuccess];
    }
}

#pragma mark - Recover Password

-(void) recoverPasswordForEmail:(NSString*) email {
    [awsService recoverPasswordForEmail:email];
}

SUBSCRIBE(AccountPasswordRecovered) {
    if(event.sender == awsService) {
        if([self.delegate respondsToSelector:@selector(recoverPasswordIsSuccess)]) {
            [self.delegate recoverPasswordIsSuccess];
        } else {
            NSLog(@"Please implement accountPasswordRecoverIsSuccess to get response");
        }
    }
}

#pragma mark - Logout user

-(void) logUserOut {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    [awsService unlinkRecorder:peppermintMessageSender.recorderId
                   fromAccount:peppermintMessageSender.accountId
                       withJwt:peppermintMessageSender.recorderJwt];
    [[PeppermintMessageSender sharedInstance] clearSender];
    
    UserLoggedOut *userLoggedOut = [UserLoggedOut new];
    userLoggedOut.sender = self;
    PUBLISH(userLoggedOut);
}

@end