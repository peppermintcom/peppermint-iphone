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
#import "GDataContacts.h"

@implementation LoginModel {
    AccountModel *accountModel;
}

-(id) init {
    self = [super init];
    if(self) {
        self.peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    }
    return self;
}

#pragma mark - Google Login

-(void) performGoogleLogin {
    GIDSignIn *gIDSignIn = [GIDSignIn sharedInstance];
    gIDSignIn.delegate = self;
    gIDSignIn.uiDelegate = self;
    
    gIDSignIn.scopes = [NSArray arrayWithObject:@"https://www.googleapis.com/auth/contacts.readonly"];
    
    
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
        [self.delegate loginFinishedLoading];
        if(error.code == -5) {
            NSLog(@"The user cancelled the login process");
        } else {
            [self.delegate operationFailure:error];
        }
    } else {
        self.peppermintMessageSender.loginSource = LOGINSOURCE_GOOGLE;
        if(user.profile.name) {
            self.peppermintMessageSender.nameSurname = user.profile.name;
        }
        if(user.profile.email) {
            self.peppermintMessageSender.email = user.profile.email;
        }
      
      self.peppermintMessageSender.subject = LOC(@"Mail Subject",@"Default Mail Subject");

        NSURL *imageUrl = [user.profile imageURLWithDimension:100];
        self.peppermintMessageSender.imageData = [NSData dataWithContentsOfURL:imageUrl];
        if([self.peppermintMessageSender isValid]) {
            [self.peppermintMessageSender save];
            [self.delegate loginSucceed];
        }
        
        //[self testGoogleContacts:signIn didSignInForUser:user];
        [signIn signOut];
    }
}

#pragma mark - Google Contacts
/*
- (GDataServiceGoogleContact *)contactService {
    
    static GDataServiceGoogleContact* service = nil;
    
    if (!service) {
        service = [[GDataServiceGoogleContact alloc] init];
        
        [service setShouldCacheResponseData:YES];
        [service setServiceShouldFollowNextLinks:YES];
    }
    
    // update the username/password each time the service is requested
    NSString *username = @"okankurtulus@gmail.com";
    NSString *password = @"OkanMilica123";
    
    [service setUserCredentialsWithUsername:username
                                   password:password];
    
    return service;
}

-(void) testGoogleContacts:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user
{
    
    [self setGroupFeed:nil];
    [self setGroupFetchError:nil];
    [self setGroupFetchTicket:nil];
    
    // we will fetch contacts next
    [self setContactFeed:nil];
    
    GDataServiceGoogleContact *service = [self contactService];
    GDataServiceTicket *ticket;
    
    BOOL showDeleted = ([mShowDeletedCheckbox state] == NSOnState);
    
    // request a whole buncha groups; our service object is set to
    // follow next links as well in case there are more than 2000
    const int kBuncha = 2000;
    
    NSURL *feedURL = [self groupFeedURL];
    
    GDataQueryContact *query = [GDataQueryContact contactQueryWithFeedURL:feedURL];
    [query setShouldShowDeleted:showDeleted];
    [query setMaxResults:kBuncha];
    
    ticket = [service fetchFeedWithQuery:query
                                delegate:self
                       didFinishSelector:@selector(groupsFetchTicket:finishedWithFeed:error:)];
    
    [self setGroupFetchTicket:ticket];
    
    [self updateUI];
}

-(void) contactsFetchTicket:(GDataServiceTicket*)ticket finishedWithFeed:(NSArray*)contacts error:(NSError*)error {
    NSLog(@"contacts : %@", contacts);
    
    for (int i = 0; i < [contacts count]; i++) {
        GDataEntryContact *contact = [contacts objectAtIndex:i];
        //        NSLog(@">>>>>>>>>>>>>>>> elementname contact :%@", [[[contact name] fullName] contentStringValue]);
        NSString *ContactName = [[[contact name] fullName] contentStringValue];
        GDataEmail *email = [[contact emailAddresses] objectAtIndex:0];
        //        NSLog(@">>>>>>>>>>>>>>>> Contact's email id :%@ contact name :%@", [email address], ContactName);
        NSString *ContactEmail = [email address];
        
        NSLog(@"Contact : %@, %@", ContactName, ContactEmail);
    }
}
*/

#pragma mark - Facebook Login

-(void) performFacebookLogin {
    if ([FBSDKAccessToken currentAccessToken]) {
        [self.delegate loginLoading];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name, email, picture"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if(error) {
                 [self.delegate loginFinishedLoading];
                 [self.delegate operationFailure:error];
             } else {
                 NSDictionary *infoDictionary = (NSDictionary*)result;
                 self.peppermintMessageSender.loginSource = LOGINSOURCE_FACEBOOK;
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
                 self.peppermintMessageSender.subject = LOC(@"Mail Subject",@"Default Mail Subject");
                 
                 if([self.peppermintMessageSender isValid]) {
                     [self.peppermintMessageSender save];
                     [self.delegate loginSucceed];
                 } else {
                     [self.delegate loginFinishedLoading];
                     [self showErrorForInformationFromFacebook];
                 }
             }
         }];
    } else {
        [self authorizeFacebook];
    }
}

-(void) authorizeFacebook {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut]; //Fix, if user changes account,(http://stackoverflow.com/a/30388750/5171866)
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
             [self performFacebookLogin];
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
    if(self.peppermintMessageSender.isValid) {
        self.peppermintMessageSender.loginSource = LOGINSOURCE_PEPPERMINT;
        self.peppermintMessageSender.imageData = [NSData new];
        self.peppermintMessageSender.subject = LOC(@"Mail Subject",@"Default Mail Subject");
        accountModel = [AccountModel sharedInstance];
        accountModel.delegate = self;
        [self.delegate loginLoading];
        [accountModel authenticate:self.peppermintMessageSender];
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
    self.peppermintMessageSender.email = email;
    self.peppermintMessageSender.password = password;
    self.peppermintMessageSender.jwt = jwt;
    self.peppermintMessageSender.isEmailVerified = NO;
    [self.peppermintMessageSender save];
    [self.delegate loginRequireEmailVerification];
}

-(void) userLogInSuccessWithEmail:(NSString*) email {
    [self.delegate loginFinishedLoading];
    [self.peppermintMessageSender save];
    [self.delegate loginSucceed];
}

-(void) verificationEmailSendSuccess {
    NSLog(@"verificationEmailSendSuccess");
}

-(void) accountInfoRefreshSuccess {
    NSLog(@"accountInfoRefreshSuccess");
}

@end