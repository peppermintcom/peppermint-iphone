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

@protocol LoginModelDelegate <BaseModelDelegate>
-(void) loginLoading;
-(void) loginFinishedLoading;
-(void) loginSucceed;
@end

@interface LoginModel : BaseModel <GIDSignInDelegate, GIDSignInUIDelegate>
@property (weak, nonatomic) UIViewController<LoginModelDelegate>* delegate;
@property (strong, nonatomic) PeppermintMessageSender *peppermintMessageSender;

-(void) performGoogleLogin;
-(void) performFacebookLogin;
-(void) performEmailLogin;

@end
