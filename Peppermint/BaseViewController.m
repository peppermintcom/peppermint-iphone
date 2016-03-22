//
//  BaseViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginNavigationViewController.h"
#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"colorfill"]];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:self.title contentType:NSStringFromClass(self.class) contentId:self.title customAttributes:@{}];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
    [AppDelegate handleError:error];
}

#pragma mark - Settings Page

-(void) redirectToSettingsPageForPermission {
    if(UIApplicationOpenSettingsURLString != nil) {
        NSURL *appSettingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:appSettingsUrl];
    } else {
        NSString *title = LOC(@"Information", @"Title Message");
        NSString *message = LOC(@"Settings URL is not supported", @"Information Message");
        NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
    }
}

#pragma mark - Login

-(BOOL) checkIfuserIsLoggedIn {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    if(!peppermintMessageSender.isValidToUseApp) {
        [LoginNavigationViewController logUserInWithDelegate:nil completion:nil];
        return NO;
    }
    return YES;
}

@end