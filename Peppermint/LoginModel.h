//
//  LoginModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import "PeppermintMessageSender.h"

@protocol LoginModelDelegate <BaseModelDelegate>
-(void) loginSucceed;
@end

@interface LoginModel : BaseModel
@property (weak, nonatomic) id<LoginModelDelegate> delegate;
@property (strong, nonatomic) PeppermintMessageSender *peppermintMessageSender;

-(void) performGoogleLogin;
-(void) performFacebookLogin;
-(void) performEmailLogin;

@end
