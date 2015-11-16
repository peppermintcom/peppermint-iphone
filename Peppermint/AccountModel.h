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
@optional
-(void) userRegisterSuccessWithEmail:(NSString*) email password:(NSString*) password jwt:(NSString*) jwt;
-(void) userLogInSuccessWithEmail:(NSString*) email;
-(void) verificationEmailSendSuccess;
@end

@interface AccountModel : BaseModel
@property (weak, nonatomic) id<AccountModelDelegate> delegate;

-(void) authenticate:(PeppermintMessageSender*) peppermintMessageSender;
-(void) resendVerificationEmail:(PeppermintMessageSender*) peppermintMessageSender;

@end
