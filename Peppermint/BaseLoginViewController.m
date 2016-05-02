//
//  BaseLoginViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 25/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseLoginViewController.h"
#import "PeppermintMessageSender.h"

@interface BaseLoginViewController ()

@end

@implementation BaseLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.referanceDate = nil;
}

-(void) showInternetIsNotReachableError {
    NSString *title = LOC(@"Information", @"Information");
    NSString *message = LOC(@"You should have internet connection to login", @"Message");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

#pragma mark - WithoutLoginLabelPressed

-(void) withoutLoginLabelPressed:(id) sender {
    NSLog(@"withoutLoginLabelPressed");
    LoginNavigationViewController *loginNavigationViewController = (LoginNavigationViewController*)self.navigationController;
    [PeppermintMessageSender sharedInstance].loginSource = LOGINSOURCE_WITHOUTLOGIN;
    [loginNavigationViewController.loginModel performWithoutLoginAuthentication];
}

@end
