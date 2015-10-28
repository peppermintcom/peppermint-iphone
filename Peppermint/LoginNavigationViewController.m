//
//  LoginNavigationViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginNavigationViewController.h"
#import "AppDelegate.h"

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

-(void) loginSucceed {
    [self dismissViewControllerAnimated:YES completion:^{
        PeppermintMessageSender *peppermintMessageSender = self.loginModel.peppermintMessageSender;
        [self.loginDelegate loginSucceedWithMessageSender:peppermintMessageSender];
    }];
}

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
    NSString *title = LOC(@"An error occured", @"Error Title Message");
    NSString *message = error.description;
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue %@ is performing", segue.identifier);
    NSLog(@"Destination viewcontroller is %@", [segue destinationViewController].class);
}

#pragma mark - PresentLoginModalView

+(void) logUserInWithDelegate:(id<LoginNavigationViewControllerDelegate>) delegate {
    UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    LoginNavigationViewController *loginNavigationViewController = [storyboard instantiateInitialViewController];
    loginNavigationViewController.loginDelegate = delegate;
    [rootVC presentViewController:loginNavigationViewController animated:YES completion:^{
        NSLog(@"Login is shown!");
    }];
}

@end
