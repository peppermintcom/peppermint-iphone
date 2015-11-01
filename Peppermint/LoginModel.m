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

-(void) performGoogleLogin {
    self.peppermintMessageSender.nameSurname = @"Google User";
    self.peppermintMessageSender.email = @"okankurtulus@yahoo.com";
    [self.peppermintMessageSender save];
    [self.delegate loginSucceed];
}

-(void) performFacebookLogin {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];    
    [login logInWithReadPermissions: @[@"public_profile"]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
             [self.delegate operationFailure:error];
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             if ([FBSDKAccessToken currentAccessToken]) {
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name, email, picture"}]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      if(error) {
                          [self.delegate operationFailure:error];
                      } else {
                          NSDictionary *infoDictionary = (NSDictionary*)result;
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
                              NSLog(@"Could not get all needed information from facebook!");
                          }
                      }
                  }];
             }
         }
     }];
}

-(void) performEmailLogin {
    self.peppermintMessageSender.imageData = [NSData new];
    [self.peppermintMessageSender save];
    [self.delegate loginSucceed];
}

@end