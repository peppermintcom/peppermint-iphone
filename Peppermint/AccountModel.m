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
    if([event.user.email isEqualToString:cachedSender.email]) {
        cachedSender.jwt = event.jwt;
        cachedSender.accountId = event.user.account_id;
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
    if(event.sender == awsService) {
        NSError *error = event.error;
        [self.delegate operationFailure:error];
    }
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
  if ([self.delegate respondsToSelector:@selector(emailChecked:)]) {
    [self.delegate emailChecked:event.isFree];
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

@end
