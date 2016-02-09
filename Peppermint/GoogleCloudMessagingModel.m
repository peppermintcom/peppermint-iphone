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
#import "ChatModel.h"
#import "PeppermintContact.h"
#import "ContactsModel.h"

#define RETRY_LIMIT_ON_ERROR    5

@implementation GoogleCloudMessagingModel {
    NSMutableSet *errorMessagesSet;
    int sameErrorOccuredCount;
    ChatModel *chatModel;
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
        errorMessagesSet = [NSMutableSet new];
        sameErrorOccuredCount = 0;
        chatModel = [ChatModel new];
    }
    return self;
}

-(void) initGCM {
    // [START_EXCLUDE]
    _registrationKey = @"onRegistrationCompleted";
    _messageKey = @"onMessageReceived";
    // Configure the Google context: parses the GoogleService-Info.plist, and initializes
    // the services that have entries in the file
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
    // Register for remote notifications
    // iOS 8 or later
    // [END_EXCLUDE]
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    // [END register_for_remote_notifications]
    // [START start_gcm_service]
    GCMConfig *gcmConfig = [GCMConfig defaultConfig];
    gcmConfig.receiverDelegate  = self;
    [[GCMService sharedInstance] startWithConfig:gcmConfig];
    // [END start_gcm_service]
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
        }
    };
}

#pragma mark - GCM Connection

-(BOOL) shouldTryAgainForError:(NSError*) error {
    if([errorMessagesSet containsObject:error.localizedDescription]) {
        sameErrorOccuredCount++;
    }
    [errorMessagesSet addObject:error.localizedDescription];
    return sameErrorOccuredCount < RETRY_LIMIT_ON_ERROR;
}


- (void) connectGCM {
    // Connect to the GCM server to receive non-APNS notifications
    [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
            if([self shouldTryAgainForError:error]) {
                [self connectGCM];
            }
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

-(Attribute*) handleIncomingMessage:(NSDictionary *) userInfo {
    NSError *error;
    Attribute *attribute = [[Attribute alloc] initWithDictionary:userInfo error:&error];
    if(!error) {
        PeppermintContact *peppermintContact = nil;
        NSPredicate *contactPredicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:attribute.sender_email communicationChannel:CommunicationChannelEmail];
        NSArray *filteredContactsArray = [[ContactsModel sharedInstance].contactList filteredArrayUsingPredicate:contactPredicate];
        if(filteredContactsArray.count > 0) {
            peppermintContact = filteredContactsArray.firstObject;
        } else {
            peppermintContact = [PeppermintContact new];
            peppermintContact.nameSurname = attribute.sender_name;
            peppermintContact.communicationChannel = CommunicationChannelEmail;
            peppermintContact.communicationChannelAddress = attribute.sender_email;
        }
        
        #warning "Add transcription and set duration"
        
            NSTimeInterval duration = 0;
            [chatModel createChatHistoryFor:peppermintContact
                              withAudioData:nil
                                   audioUrl:attribute.audio_url
                              transcription:@"Transcription"
                                   duration:duration
                                 isSentByMe:NO
                                 createDate:attribute.createdDate];
        
    } else {
        attribute = nil;
        NSLog(@"Could not parse userInfo. Notification could not be processed:\n%@", userInfo);
    }
    return attribute;
}

@end
