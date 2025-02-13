//
//  LoginNavigationViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginNavigationViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "LoginValidateEmailViewController.h"

@interface LoginNavigationViewController ()
@property (weak, nonatomic) id<LoginNavigationViewControllerDelegate> loginDelegate;
@end

@implementation LoginNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginModel = [LoginModel new];
    self.loginModel.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - LoginModelDelegate

-(void) loginLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
}

-(void) loginFinishedLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

-(void) loginSucceed {
    weakself_create();
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [weakSelf loginFinishedLoading];
            PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
            [weakSelf.loginDelegate loginSucceedWithMessageSender:peppermintMessageSender];
            
            NewUserLoggedIn *newUserLoggedIn = [NewUserLoggedIn new];
            newUserLoggedIn.sender = self;
            PUBLISH(newUserLoggedIn);
        }];
    });
}

-(void) loginRequireEmailVerification {
    LoginValidateEmailViewController *loginValidateEmailViewController =
    (LoginValidateEmailViewController*) [self.storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_LOGINVALIDATE];
    loginValidateEmailViewController.loginModel = self.loginModel;
    [self pushViewController:loginValidateEmailViewController animated:YES];
}

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
    [self loginFinishedLoading];
    [AppDelegate handleError:error];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue %@ is performing", segue.identifier);
    NSLog(@"Destination viewcontroller is %@", [segue destinationViewController].class);
}

#pragma mark - PresentLoginModalView

+(void) logUserInWithDelegate:(id<LoginNavigationViewControllerDelegate>) delegate completion:(void(^)(void))completion {
    UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_LOGIN bundle:[NSBundle mainBundle]];
    LoginNavigationViewController *loginNavigationViewController = [storyboard instantiateInitialViewController];
    loginNavigationViewController.loginDelegate = delegate;
    
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    
    [UIView animateWithDuration:0.2 animations:^{
        rootVC.view.alpha = 0.2;
    }];
    [rootVC presentViewController:loginNavigationViewController animated:YES completion:^{
        rootVC.view.alpha = 1;
        if([peppermintMessageSender isInMailVerificationProcess]) {
            [loginNavigationViewController loginRequireEmailVerification];
        }
        if(completion) { completion(); }        
    }];
}

@end
