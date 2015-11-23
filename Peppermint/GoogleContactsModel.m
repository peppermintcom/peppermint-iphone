//
//  GoogleContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 23/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "GoogleContactsModel.h"

#define CONTACTS_URL_PATH       @"https://www.google.com/m8/feeds/contacts/default/full"
#define NEXT_RELATION           @"next"

@implementation GoogleContactsModel {
    id<GTMFetcherAuthorizationProtocol> _fetcherAuthorizer;
}

#pragma mark - Google Contacts

+(NSString*) scopeForGoogleContacts {
    return @"https://www.googleapis.com/auth/contacts.readonly";
}

-(void) syncGoogleContactsWithFetcherAuthorizer:(id<GTMFetcherAuthorizationProtocol>)fetcherAuthorizer {
    _fetcherAuthorizer = fetcherAuthorizer;
    dispatch_async(LOW_PRIORITY_QUEUE, ^{
        [self queryForUrlPath:CONTACTS_URL_PATH];
    });
}

-(void) queryForUrlPath:(NSString*) urlPath {
    NSURL *url = [NSURL URLWithString:urlPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [_fetcherAuthorizer authorizeRequest:request completionHandler:^(NSError* error){
        if(error) {
            [self.delegate operationFailure:error];
        } else {
            [self processRequest:request];
        }
    }];
}

-(void) processRequest:(NSURLRequest*) request {
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error) {
        [self.delegate operationFailure:error];
    } else if (data) {
        GDataFeedBase *feed = [GDataFeedBase feedWithXMLData:data];
        [self processEntries:feed.entries];
        [self checkForNextUrl:feed];
    }
}

-(void) checkForNextUrl:(GDataFeedBase*) feed {
    NSString *nextUrlPath = nil;
    for(GDataLink *link in feed.links) {
        if([link.rel isEqualToString:NEXT_RELATION]) {
            nextUrlPath = link.href;
            break;
        }
    }
    if(nextUrlPath) {
        [self queryForUrlPath:nextUrlPath];
    }
}

-(void) processEntries:(NSArray*) entries {
    for (GDataEntryContact *contactEntry in entries) {
        for(GDataEmail* gDataEmail in contactEntry.emailAddresses) {
            NSLog(@"Contact : %@ %@", contactEntry.title.stringValue, gDataEmail.address);
        }
    }
}

@end
