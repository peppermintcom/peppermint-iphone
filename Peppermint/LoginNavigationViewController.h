//
//  LoginNavigationViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginModel.h"

@protocol LoginNavigationViewControllerDelegate <NSObject>
-(void) loginSucceedWithMessageSender:(PeppermintMessageSender*) peppermintMessageSender;
@end

@interface LoginNavigationViewController : UINavigationController <LoginModelDelegate>
@property (strong, nonatomic) LoginModel *loginModel;

+(void) logUserInWithDelegate:(id<LoginNavigationViewControllerDelegate>) delegate completion:(void(^)(void))completion;
@end
