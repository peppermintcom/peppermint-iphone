//
//  LoginModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginModel.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@implementation LoginModel

-(id) init {
    self = [super init];
    if(self) {
        self.peppermintMessageSender = [PeppermintMessageSender new];
    }
    return self;
}

#pragma mark - Google Login

-(void) performGoogleLogin {
    GIDSignIn *gIDSignIn = [GIDSignIn sharedInstance];
    gIDSignIn.delegate = self;
    gIDSignIn.uiDelegate = self;
    [self.delegate loginLoading];
    [gIDSignIn signIn];
}

#pragma mark - GoogleSignInUIDelegate

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    NSLog(@"signInWillDispatch:__");
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    NSLog(@"signIn:(GIDSignIn *)signIn presentViewController:");
    [self.delegate presentViewController:viewController animated:YES completion:nil];;
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    NSLog(@"signIn:(GIDSignIn *)signIn dismissViewController:");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if(error) {
        if(error.code == -5) {
            [self.delegate loginFinishedLoading];
            NSLog(@"The user cancelled the login process");
        } else {
            [self.delegate operationFailure:error];
        }
    } else {
        self.peppermintMessageSender.loginSource = LOGINSOURCE_GOOGLE;
        self.peppermintMessageSender.password = @"***";
        if(user.profile.name) {
            self.peppermintMessageSender.nameSurname = user.profile.name;
        }
        if(user.profile.email) {
            self.peppermintMessageSender.email = user.profile.email;
        }
        NSURL *imageUrl = [user.profile imageURLWithDimension:100];
        self.peppermintMessageSender.imageData = [NSData dataWithContentsOfURL:imageUrl];
        if([self.peppermintMessageSender isValid]) {
            [self.peppermintMessageSender save];
            [self.delegate loginSucceed];
        }
        [signIn signOut];
    }
}

#pragma mark - Facebook Login

-(void) performFacebookLogin {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [self.delegate loginLoading];
    [login logInWithReadPermissions: @[@"public_profile",@"email"]
     fromViewController:self.delegate
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
             [self.delegate operationFailure:error];
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
             [self.delegate loginFinishedLoading];
         } else {
             if ([FBSDKAccessToken currentAccessToken]) {
                 [self.delegate loginLoading];
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name, email, picture"}]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      if(error) {
                          [self.delegate operationFailure:error];
                      } else {
                          NSDictionary *infoDictionary = (NSDictionary*)result;
                          self.peppermintMessageSender.loginSource = LOGINSOURCE_FACEBOOK;
                          self.peppermintMessageSender.password = @"***";
                          if([infoDictionary.allKeys containsObject:@"name"]) {
                              self.peppermintMessageSender.nameSurname = [result valueForKey:@"name"];
                          }
                          if([infoDictionary.allKeys containsObject:@"email"]) {
                              self.peppermintMessageSender.email = [result valueForKey:@"email"];
                          }
                          if([infoDictionary.allKeys containsObject:@"picture"]) {
                              NSString *urlPath = [result valueForKeyPath:@"picture.data.url"];
                              NSURL *url = [NSURL URLWithString:urlPath];
                              NSData *data = [NSData dataWithContentsOfURL:url];
                              self.peppermintMessageSender.imageData = data;
                          }
                          if([self.peppermintMessageSender isValid]) {
                              [login logOut];
                              [self.peppermintMessageSender save];
                              [self.delegate loginSucceed];
                          } else {
                              [self showErrorForInformationFromFacebook];
                          }
                      }
                  }];
             }
         }
     }];
}

-(void) showErrorForInformationFromFacebook
{
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Could not get all needed information from facebook!", @"Information Message");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

#pragma mark - Email Login

-(void) performEmailLogin {
    self.peppermintMessageSender.loginSource = LOGINSOURCE_PEPPERMINT;
    self.peppermintMessageSender.imageData = [NSData new];
    [self.peppermintMessageSender save];
    [self.delegate loginSucceed];
}

@end