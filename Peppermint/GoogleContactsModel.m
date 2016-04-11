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
#import "Repository.h"

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
        //NSString * myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
    } else {
        NSLog(@"SyncGoogleContactsSuccess");
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(syncGoogleContactsSuccess)]) {
            [self.delegate syncGoogleContactsSuccess];
        } else {
            SyncGoogleContactsSuccess *syncGoogleContactsSuccess = [SyncGoogleContactsSuccess new];
            syncGoogleContactsSuccess.sender = self;
            PUBLISH(syncGoogleContactsSuccess);
        }
    }
}

-(void) processEntries:(NSArray*) entries {
    for (GDataEntryContact *contactEntry in entries) {

        NSString *name = [[contactEntry name] fullName].stringValue;
        name = name ? name : contactEntry.title.stringValue;

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
                    if(photoData != nil) {
                        for(GDataEmail* gDataEmail in contactEntry.emailAddresses) {
                            [self saveContactWithName:name email:gDataEmail.address imageData:photoData identifier:contactEntry.identifier];
                        }
                    }
                }
            }];
        } else {
            for(GDataEmail* gDataEmail in contactEntry.emailAddresses) {
                [self saveContactWithName:name email:gDataEmail.address imageData:nil identifier:contactEntry.identifier];
            }
        }
    }
}

-(void) saveContactWithName:(NSString*) name email:(NSString*) email imageData:(NSData*)imageData identifier:(NSString*) identifier {
    if([email isValidEmail]) {
        name = name && name.length > 0 ? name : email;
        Repository *repository = [Repository beginTransaction];
        
        NSPredicate *predicate = [ContactsModel contactPredicateWithNameSurname:name
                                                    communicationChannelAddress:email
                                                           communicationChannel:CommunicationChannelEmail];
        NSArray *matchedContacts = [repository getResultsFromEntity:[GoogleContact class] predicateOrNil:predicate];
        if(matchedContacts.count == 0) {
            GoogleContact *googleContact = (GoogleContact*)[repository createEntity:[GoogleContact class]];
            googleContact.nameSurname = name;
            googleContact.communicationChannelAddress = email;
            googleContact.communicationChannel = [NSNumber numberWithInt:CommunicationChannelEmail];
            googleContact.avatarImageData = imageData;
            googleContact.accountEmail = [_fetcherAuthorizer userEmail];
            googleContact.identifier = identifier;
            NSError *err = [repository endTransaction];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(err) {
                    [self.delegate operationFailure:err];
                }
            });
        } else {
            NSLog(@"Contact is not saved because it already exists.");
        }
    }
}

#pragma mark - Fetch PeppermintContact Array

+(NSArray*) peppermintContactsArrayWithFilterText:(NSString*) filterText {
    
    NSMutableArray *peppermintContactArray = [NSMutableArray new];
    NSPredicate *namePredicate = [ContactsModel contactPredicateWithNameSurname:filterText];
    NSPredicate *mailPredicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:filterText communicationChannel:CommunicationChannelEmail];
    NSPredicate *googlePredicate = nil;
    if(filterText.length > 0) {
        googlePredicate = [NSCompoundPredicate orPredicateWithSubpredicates:
                           [NSArray arrayWithObjects:namePredicate, mailPredicate, nil]];
    }
    
    Repository *repository = [Repository beginTransaction];
    NSArray *matchingGoogleContacts = [repository getResultsFromEntity:[GoogleContact class] predicateOrNil:googlePredicate];
    
    for(GoogleContact *matchedGoogleContact in matchingGoogleContacts) {
        PeppermintContact *peppermintContact = [PeppermintContact new];
        peppermintContact.uniqueContactId = [NSString stringWithFormat:@"%@%d",
                                             CONTACT_GOOGLE, matchedGoogleContact.identifier.hash];
        peppermintContact.avatarImage = [UIImage imageWithData:matchedGoogleContact.avatarImageData];
        peppermintContact.nameSurname = matchedGoogleContact.nameSurname;
        peppermintContact.communicationChannel = matchedGoogleContact.communicationChannel.intValue;
        peppermintContact.communicationChannelAddress = matchedGoogleContact.communicationChannelAddress;
        [peppermintContactArray addObject:peppermintContact];
    }
    [repository endTransaction];
    return peppermintContactArray;
}

@end
