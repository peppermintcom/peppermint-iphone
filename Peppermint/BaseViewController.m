//
//  BaseViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ConnectionModel.h"

@interface BaseViewController ()

@end

@implementation BaseViewController {
    ConnectionModel *connectionModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    connectionModel = [ConnectionModel new];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"colorfill"]];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
    NSString *title = LOC(@"An error occured", @"Error Title Message");
    NSString *message = error.description;
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
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

@end