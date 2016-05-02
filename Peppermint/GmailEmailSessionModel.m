//
//  GmailEmailSessionModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "GmailEmailSessionModel.h"
#import "PeppermintMessageSender.h"
#import "PeppermintGIdSignIn.h"

#define GOOGLE_INBOX        @"INBOX"
#define GOOGLE_SENT         @"[Gmail]/Sent Mail"

@interface GmailEmailSessionModel() <GIDSignInDelegate, GIDSignInUIDelegate>
@end

@implementation GmailEmailSessionModel
@dynamic delegate;

-(void) initSession {
    self.folderInbox = GOOGLE_INBOX;
    self.folderSent = GOOGLE_SENT;
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    if(peppermintMessageSender.loginSource == LOGINSOURCE_GOOGLE) {
        if(![GIDSignIn sharedInstance].currentUser) {
            [self tryGoogleSilentSignIn];
        } else {
            [self startToListenInbox];
        }
    }
}

-(MCOIMAPSession*) session {
    if(!_session) {
        _session = [MCOIMAPSession new];
        _session.hostname = @"imap.gmail.com";
        _session.port = 993;
        [_session setAuthType:MCOAuthTypeXOAuth2];
        [_session setOAuth2Token:[PeppermintGIdSignIn GIdSignInInstance].currentUser.authentication.accessToken];
        [_session setUsername:[PeppermintGIdSignIn GIdSignInInstance].currentUser.profile.email];
        [_session setPassword:nil];
        _session.connectionType = MCOConnectionTypeTLS;
        _session.checkCertificateEnabled = NO;
        [self setLoggerActive:NO];
    }
    return _session;
}

-(void) tryGoogleSilentSignIn {
    GIDSignIn *gIDSignIn = [PeppermintGIdSignIn GIdSignInInstance];
    BOOL hasAuth = gIDSignIn.hasAuthInKeychain;
    if(hasAuth) {
        gIDSignIn.delegate = self;
        [gIDSignIn signInSilently];
    } else {
        NSLog(@"Account is not signed in yet.");
    }
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if(error) {
        NSLog(@"Google Silent SignIn Error: %@", error);
        [self.delegate operationFailure:error];
    } else {
        [self initSession];
    }
}

@end
