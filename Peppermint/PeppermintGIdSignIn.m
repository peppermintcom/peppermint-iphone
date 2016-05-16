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
    //Don't set delegates, cos it must be handled in source of function call
    //gIDSignIn.delegate = nil;
    //gIDSignIn.uiDelegate = nil;
    
    NSMutableArray *scopesArray = [NSMutableArray new];
    [scopesArray addObject:[GoogleContactsModel scopeForGoogleContacts]];
    //[scopesArray addObject:[GoogleEmailModel scopeForReadGoogleMails]];
    gIDSignIn.scopes = scopesArray;
    return gIDSignIn;
}

@end
