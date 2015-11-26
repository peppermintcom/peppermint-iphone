//
//  GoogleContactsModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 23/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "GoogleContactsModel.h"
#import "ContactsModel.h"
#import <Google/SignIn.h>
#import "Events.h"

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
        
        NSString* responseText = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"\nr:\n%@", responseText);
        
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
    
    RetrieveGoogleContactsIsSuccessful *retrieveGoogleContactsIsSuccessful = [RetrieveGoogleContactsIsSuccessful new];
    retrieveGoogleContactsIsSuccessful.hasNext = nextUrlPath.length > 0;
    PUBLISH(retrieveGoogleContactsIsSuccessful);
    
    if(nextUrlPath) {
        [self queryForUrlPath:nextUrlPath];
    }
}

-(void) processEntries:(NSArray*) entries {
    for (GDataEntryContact *contactEntry in entries) {
        NSString *name = [[contactEntry name] fullName].stringValue;
        __block UIImage *image = nil;
        GDataLink *link = [contactEntry photoLink];
        if(link != nil) {
            NSURL *photoUrl = [NSURL URLWithString:link.href];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:photoUrl];
            [_fetcherAuthorizer authorizeRequest:request completionHandler:^(NSError* error) {
                if(error) {
                    [self.delegate operationFailure:error];
                } else {
                    NSURLResponse *response = nil;
                    NSData *photoData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                    image = [UIImage imageWithData:photoData];
                    if(image != nil) {
                        for(GDataEmail* gDataEmail in contactEntry.emailAddresses) {
                            [self addContactAsExternalContactWithName:name email:gDataEmail.address image:image];
                        }
                    }
                }
            }];
        } else {
            for(GDataEmail* gDataEmail in contactEntry.emailAddresses) {
                [self addContactAsExternalContactWithName:name email:gDataEmail.address image:nil];
            }
        }
    }
}

-(void) addContactAsExternalContactWithName:(NSString*) name email:(NSString*) email image:(UIImage*) image {
    if([email isValidEmail]) {
        name = name && name.length > 0 ? name : email;
        PeppermintContact *peppermintContact = [PeppermintContact new];
        peppermintContact.communicationChannel = CommunicationChannelEmail;
        peppermintContact.communicationChannelAddress = email;
        peppermintContact.nameSurname = name;
        peppermintContact.avatarImage = image;
        [[ContactsModel sharedInstance] addExternalContact:peppermintContact];
    }
}

@end
