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
#import "GoogleContactsModel.h"

@implementation LoginModel {
    AccountModel *accountModel;
    PeppermintMessageSender *peppermintMessageSender;
}

-(id) init {
    self = [super init];
    if(self) {
        peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    }
    return self;
}

#pragma mark - Google Login

-(void) performGoogleLogin {
    GIDSignIn *gIDSignIn = [GIDSignIn sharedInstance];
    gIDSignIn.delegate = self;
    gIDSignIn.uiDelegate = self;
    
    NSMutableArray *scopesArray = [NSMutableArray new];
    [scopesArray addObject:[GoogleContactsModel scopeForGoogleContacts]];
    gIDSignIn.scopes = scopesArray;
    [self.delegate loginLoading];
    [gIDSignIn signOut];
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
        [self.delegate loginFinishedLoading];
        if(error.code == -5) {
            NSLog(@"The user cancelled the login process");
        } else {
            [self.delegate operationFailure:error];
        }
    } else {
        peppermintMessageSender.loginSource = LOGINSOURCE_GOOGLE;
        if(user.profile.name) {
            peppermintMessageSender.nameSurname = user.profile.name;
        }
        if(user.profile.email) {
            peppermintMessageSender.email = user.profile.email;
        }
      
        peppermintMessageSender.subject = LOC(@"Mail Subject",@"Default Mail Subject");

        NSURL *imageUrl = [user.profile imageURLWithDimension:100];
        peppermintMessageSender.imageData = [NSData dataWithContentsOfURL:imageUrl];
        if([peppermintMessageSender isValid]) {
            [peppermintMessageSender save];
            [self.delegate loginSucceed];
        }
        
        
        GoogleContactsModel *googleContactsModel = [GoogleContactsModel new];
        [googleContactsModel syncGoogleContactsWithFetcherAuthorizer:user.authentication.fetcherAuthorizer];
    }
}

#pragma mark - Facebook Login

-(void) performFacebookLogin {
    //[self performFacebookLoginOperations];
    [self authorizeFacebook];
}

-(void) authorizeFacebook {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut]; //this is added to fix, if user changes account,(http://stackoverflow.com/a/30388750/5171866)
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [self.delegate loginLoading];
    
    login.loginBehavior = FBSDKLoginBehaviorBrowser;
    
    [login logInWithReadPermissions: @[@"public_profile",@"email"]
     fromViewController:self.delegate
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         [self.delegate loginFinishedLoading];
         if (error) {
             NSLog(@"Process error");
             [self.delegate operationFailure:error];
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
             [self.delegate loginFinishedLoading];
         } else {
             [self performFacebookLoginOperations];
         }
     }];
}

-(void) performFacebookLoginOperations {
    if ([FBSDKAccessToken currentAccessToken]) {
        [self.delegate loginLoading];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name, email, picture"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             [self.delegate loginFinishedLoading];
             if(error) {
                 [self.delegate operationFailure:error];
             } else {
                 NSDictionary *infoDictionary = (NSDictionary*)result;
                 peppermintMessageSender.loginSource = LOGINSOURCE_FACEBOOK;
                 if([infoDictionary.allKeys containsObject:@"name"]) {
                     peppermintMessageSender.nameSurname = [result valueForKey:@"name"];
                 }
                 if([infoDictionary.allKeys containsObject:@"email"]) {
                     peppermintMessageSender.email = [result valueForKey:@"email"];
                 }
                 if([infoDictionary.allKeys containsObject:@"picture"]) {
                     NSString *urlPath = [result valueForKeyPath:@"picture.data.url"];
                     NSURL *url = [NSURL URLWithString:urlPath];
                     NSData *data = [NSData dataWithContentsOfURL:url];
                     peppermintMessageSender.imageData = data;
                 }
                 peppermintMessageSender.subject = LOC(@"Mail Subject",@"Default Mail Subject");
                 
                 if([peppermintMessageSender isValid]) {
                     [peppermintMessageSender save];
                     [self.delegate loginSucceed];
                 } else {
                     [self showErrorForInformationFromFacebook];
                 }
             }
         }];
    } else {
        [self authorizeFacebook];
    }
}

-(void) showErrorForInformationFromFacebook
{
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Could not get all needed information from facebook!", @"Information Message");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

#pragma mark - Email Login

-(void) performEmailSignUp {
    if(peppermintMessageSender.isValid) {
        peppermintMessageSender.loginSource = LOGINSOURCE_PEPPERMINT;
        peppermintMessageSender.imageData = [NSData new];
        peppermintMessageSender.subject = LOC(@"Mail Subject",@"Default Mail Subject");
        accountModel = [AccountModel sharedInstance];
        accountModel.delegate = self;
        [self.delegate loginLoading];
        [accountModel authenticate:peppermintMessageSender];
    } else {
        [self.delegate operationFailure:[NSError errorWithDomain:@"peppermintMessageSender is not valid!" code:-1 userInfo:nil]];
    }
}

#pragma mark - AccountModelDelegate

-(void) operationFailure:(NSError*) error {
    [self.delegate loginFinishedLoading];
    [self.delegate operationFailure:error];
}

-(void) userRegisterSuccessWithEmail:(NSString*) email password:(NSString *)password jwt:(NSString *)jwt {
    [self.delegate loginFinishedLoading];
    peppermintMessageSender.email = email;
    peppermintMessageSender.password = password;
    peppermintMessageSender.jwt = jwt;
    peppermintMessageSender.isEmailVerified = NO;
    [peppermintMessageSender save];
    [self.delegate loginRequireEmailVerification];
}

-(void) userLogInSuccessWithEmail:(NSString*) email {
    [self.delegate loginFinishedLoading];
    [peppermintMessageSender save];
    [self.delegate loginSucceed];
}

-(void) verificationEmailSendSuccess {
    NSLog(@"verificationEmailSendSuccess");
}

-(void) accountInfoRefreshSuccess {
    NSLog(@"accountInfoRefreshSuccess");
}

@end