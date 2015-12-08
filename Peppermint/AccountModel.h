//
//  AccountModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 14/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintMessageSender.h"

@protocol AccountModelDelegate <BaseModelDelegate>
-(void) userRegisterSuccessWithEmail:(NSString*) email password:(NSString*) password jwt:(NSString*) jwt;
-(void) userLogInSuccessWithEmail:(NSString*) email;
-(void) verificationEmailSendSuccess;
-(void) accountInfoRefreshSuccess;
@optional
-(void) checkEmailIsRegisteredIsSuccess:(BOOL) isEmailRegistered isEmailVerified:(BOOL) isEmailVerified;
@end

@interface AccountModel : BaseModel
@property (weak, nonatomic) id<AccountModelDelegate> delegate;

+ (instancetype) sharedInstance;
-(void) authenticate:(PeppermintMessageSender*) peppermintMessageSender;
-(void) resendVerificationEmail:(PeppermintMessageSender*) peppermintMessageSender;
-(void) refreshAccountInfo:(PeppermintMessageSender*) peppermintMessageSender;
-(void) checkEmailIsRegistered:(NSString *)email;
-(void) logUserIn:(NSString*) email password:(NSString*) password;


@end
