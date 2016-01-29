//
//  LoginModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintMessageSender.h"
#import <Google/SignIn.h>
#import "AccountModel.h"

@protocol LoginModelDelegate <BaseModelDelegate>
-(void) loginLoading;
-(void) loginFinishedLoading;
-(void) loginSucceed;
-(void) loginRequireEmailVerification;
@end

@interface LoginModel : BaseModel <GIDSignInDelegate, GIDSignInUIDelegate, AccountModelDelegate>
@property (weak, nonatomic) UIViewController<LoginModelDelegate>* delegate;

-(void) performGoogleLogin;
-(void) performFacebookLogin;
-(void) performEmailSignUp;
-(void) performWithoutLoginAuthentication;

@end
