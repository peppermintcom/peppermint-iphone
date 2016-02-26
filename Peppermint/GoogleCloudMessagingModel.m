//
//  GoogleCloudMessagingModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 20/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "GoogleCloudMessagingModel.h"
#import <UIKit/UIApplication.h>
#import "AppDelegate.h"
#import "PeppermintMessageSender.h"
#import "PeppermintContact.h"
#import "ContactsModel.h"
#import "RecentContactsModel.h"
#import "CustomContactModel.h"
#import "Attribute.h"
#import "ChatEntryModel.h"

@interface GoogleCloudMessagingModel() <ChatEntryModelDelegate>
@end

@implementation GoogleCloudMessagingModel {
    RecentContactsModel *recentContactsModel;
    CustomContactModel *customContactsModel;
    NSMutableSet *handledGoogleMessageIdSet;
    ChatEntryModel *chatEntryModel;
    BOOL isServiceCallActive;
    NSMutableArray *attributeEntitiesToBeProcessed;
}

NSString *const SubscriptionTopic = @"/topics/global";

+ (instancetype) sharedInstance {
    return SHARED_INSTANCE( [[self alloc] initShared] );
}

-(id) init {
    NSAssert(false, @"This model instance is singleton so should not be inited - %@", self);
    return nil;
}

-(id) initShared {
    self = [super init];
    if(self) {
        recentContactsModel = [RecentContactsModel new];
        customContactsModel = [CustomContactModel new];
        handledGoogleMessageIdSet = [NSMutableSet new];
        chatEntryModel = [ChatEntryModel new];
        chatEntryModel.delegate = self;
        isServiceCallActive = NO;
        attributeEntitiesToBeProcessed = [NSMutableArray new];
    }
    return self;
}

-(NSSet*) notificationCategories {
    UIMutableUserNotificationAction *replyAction = [UIMutableUserNotificationAction new];
    [replyAction setActivationMode:UIUserNotificationActivationModeForeground];
    replyAction.identifier = CATEGORY_IDENTIFIER_REPLY;
    replyAction.title = [NSString stringWithFormat:@"%@", LOC(@"Reply", @"Reply Action Title")];
    replyAction.authenticationRequired = YES;
    UIMutableUserNotificationCategory *gcmNotificationCategory = [UIMutableUserNotificationCategory new];
    gcmNotificationCategory.identifier = CATEGORY_GCM_AUDIO_MESSAGE;
    [gcmNotificationCategory setActions: [NSArray arrayWithObjects:replyAction, nil] forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:gcmNotificationCategory];
    return categories;
}

-(void) initGCM {
    // [START_EXCLUDE]
    _registrationKey = @"onRegistrationCompleted";
    _messageKey = @"onMessageReceived";
    _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
    
    // [END register_for_remote_notifications]
    // [START start_gcm_service]
    GCMConfig *gcmConfig = [GCMConfig defaultConfig];
    gcmConfig.receiverDelegate  = self;
    [[GCMService sharedInstance] startWithConfig:gcmConfig];
    // [END start_gcm_service]
    
    // Register for remote notifications
    // iOS 8 or later
    // [END_EXCLUDE]
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:[self notificationCategories]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    __weak typeof(self) weakSelf = self;
    // Handler for registration token request
    _registrationHandler = ^(NSString *registrationToken, NSError *error){
        if (registrationToken != nil) {
            weakSelf.registrationToken = registrationToken;
            NSLog(@"Registration Token: %@", registrationToken);
            
            PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
            NSString *existingToken = peppermintMessageSender.gcmToken;
            if(!existingToken
               || !peppermintMessageSender.isAccountSetUpWithRecorder
               || ![existingToken isEqualToString:registrationToken]) {
                [[AppDelegate Instance] tryToUpdateGCMRegistrationToken];
            }
            
            NSDictionary *userInfo = @{@"registrationToken":registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        } else {
            NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
            NSDictionary *userInfo = @{@"error":error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
            
            NSLog(@"Schedule re-init in 2 seconds!");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf initGCM];
            });
        }
    };
}

#pragma mark - GCM Connection

- (void) connectGCM {
    // Connect to the GCM server to receive non-APNS notifications
    [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
        } else {
            _connectedToGCM = true;
            NSLog(@"Connected to GCM");
            // ...
        }
    }];
}

- (void) disconnectGCM {
    [[GCMService sharedInstance] disconnect];
    _connectedToGCM = NO;
}

#pragma mark - GCMReceiverDelegate

// [START upstream_callbacks]
- (void)willSendDataMessageWithID:(NSString *)messageID error:(NSError *)error {
    NSLog(@"willSendDataMessageWithID");
    if (error) {
        // Failed to send the message.
    } else {
        // Will send message, you can save the messageID to track the message
    }
}

- (void)didSendDataMessageWithID:(NSString *)messageID {
    // Did successfully send message identified by messageID
    NSLog(@"didSendDataMessageWithID");
}
// [END upstream_callbacks]

- (void)didDeleteMessagesOnServer {
    // Some messages sent to this device were deleted on the GCM server before reception, likely
    // because the TTL expired. The client should notify the app server of this, so that the app
    // server can resend those messages.
    NSLog(@"didDeleteMessagesOnServer");
}

#pragma mark - Incoming Message

-(PeppermintContact*) tryToMatchPreSavedPeppermintContactWithEmail:(NSString*)email nameSurname:(NSString*)nameSurname {
    PeppermintContact *peppermintContact = nil;
    NSPredicate *contactPredicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:email];
    NSArray *filteredContactsArray = [[ContactsModel sharedInstance].contactList filteredArrayUsingPredicate:contactPredicate];
    if(filteredContactsArray.count > 0) {
        peppermintContact = filteredContactsArray.firstObject;
    } else {
        peppermintContact = [PeppermintContact new];
        peppermintContact.communicationChannel = CommunicationChannelEmail;
        peppermintContact.nameSurname = nameSurname;
        peppermintContact.communicationChannelAddress = email;
    }
    return peppermintContact;
}

-(PeppermintChatEntry*) createPeppermintChatEntryFromAttribute:(Attribute*) attribute {
    PeppermintChatEntry *peppermintChatEntry = [PeppermintChatEntry new];
    peppermintChatEntry.audio = nil;
    peppermintChatEntry.audioUrl = attribute.audio_url;
    peppermintChatEntry.dateCreated = attribute.createdDate;
    peppermintChatEntry.contactEmail = attribute.sender_email;
    peppermintChatEntry.contactNameSurname = attribute.sender_name;
    peppermintChatEntry.duration = attribute.duration.integerValue;
    peppermintChatEntry.isSentByMe = NO;
    return peppermintChatEntry;
}

-(BOOL) handleIncomingMessage:(NSDictionary *) userInfo {
    NSError *error;
    BOOL result = NO;
    Attribute *attribute = [[Attribute alloc] initWithDictionary:userInfo error:&error];
    
    NSLog(@"Got GCM Message:\n%@", userInfo);
    if(!error && attribute.message_id && ![handledGoogleMessageIdSet containsObject:attribute.message_id]) {        
        [handledGoogleMessageIdSet addObject:attribute.message_id];
        [attributeEntitiesToBeProcessed addObject:attribute];
        [self processAttributesArray];
        result = YES;
    }
    return result;
}

-(void) processAttributesArray {
    if(isServiceCallActive) {
        NSLog(@"Not processing in this cycle. Will process when active service call completes.");
    } else if (attributeEntitiesToBeProcessed.count == 0) {
        PUBLISH([GoogleCloudMessagingProcessedAllMessages new]);
    } else {
        isServiceCallActive = YES;
        NSLog(@"attributeEntitiesToBeProcessed has %ld queued objects...", attributeEntitiesToBeProcessed.count);
        
        Attribute *attribute = [attributeEntitiesToBeProcessed firstObject];
        PeppermintChatEntry *peppermintChatEntry = [self createPeppermintChatEntryFromAttribute:attribute];
        PeppermintContact *peppermintContact = [self tryToMatchPreSavedPeppermintContactWithEmail:attribute.sender_email
                                                                                      nameSurname:attribute.sender_name];
        [chatEntryModel createChatHistory:peppermintChatEntry forPeppermintContact:peppermintContact];
        [customContactsModel save:peppermintContact];
        [recentContactsModel save:peppermintContact forContactDate:peppermintChatEntry.dateCreated];
        [attributeEntitiesToBeProcessed removeObject:attribute];
    }
}


#pragma mark - ChatEntryModelDelegate

-(void) chatHistoryCreatedWithSuccess {
    NSLog(@"ChatHistoryCreatedWithSuccess in GCM Model");
    isServiceCallActive = NO;
    [self processAttributesArray];
}

-(void) chatEntriesArrayIsUpdated {
    NSLog(@"chatEntriesArrayIsUpdated");
}

-(void) peppermintChatEntrySavedWithSuccess:(PeppermintChatEntry*)peppermintChatEntry {
    NSLog(@"peppermintChatEntrySavedWithSuccess");
}

-(void) operationFailure:(NSError*) error {
    NSLog(@"operationFailure:%@", error.localizedDescription);
    [AppDelegate handleError:error];
}

@end
