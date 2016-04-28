//
//  PeppermintGIdSignIn.m
//  Peppermint
//
//  Created by Okan Kurtulus on 25/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "PeppermintGIdSignIn.h"
#import "GoogleContactsModel.h"
#import "GoogleEmailModel.h"

@implementation PeppermintGIdSignIn

+(GIDSignIn*) GIdSignInInstance {
    GIDSignIn *gIDSignIn = [GIDSignIn sharedInstance];
    gIDSignIn.delegate = nil;
    gIDSignIn.uiDelegate = nil;
    
    //gIDSignIn.allowsSignInWithBrowser = YES;
    //gIDSignIn.allowsSignInWithWebView = YES;
    
    NSMutableArray *scopesArray = [NSMutableArray new];
    [scopesArray addObject:[GoogleContactsModel scopeForGoogleContacts]];
    [scopesArray addObject:[GoogleEmailModel scopeForReadGoogleMails]];
    gIDSignIn.scopes = scopesArray;
    return gIDSignIn;
}

@end
