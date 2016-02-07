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

@implementation GoogleCloudMessagingModel {
    NSString *gcmSenderId;
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
            [weakSelf subscribedToTopic];
            
            NSString *existingToken = defaults_object(DEFAULTS_GCM_REGSTRATION_TOKEN);
            if(!existingToken || ![existingToken isEqualToString:registrationToken]) {
                defaults_set_object(DEFAULTS_GCM_REGSTRATION_TOKEN, registrationToken);
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

- (void)subscribeToTopic {
    // If the app has a registration token and is connected to GCM, proceed to subscribe to the
    // topic
    if (_registrationToken && _connectedToGCM) {
        [[GCMPubSub sharedInstance] subscribeWithToken:_registrationToken
                                                 topic:SubscriptionTopic
                                               options:nil
                                               handler:^(NSError *error) {
                                                   if (error) {
                                                       // Treat the "already subscribed" error more gently
                                                       if (error.code == 3001) {
                                                           NSLog(@"Already subscribed to %@",
                                                                 SubscriptionTopic);
                                                       } else {
                                                           NSLog(@"Subscription failed: %@",
                                                                 error.localizedDescription);
                                                       }
                                                   } else {
                                                       self.subscribedToTopic = true;
                                                       NSLog(@"Subscribed to %@", SubscriptionTopic);
                                                   }
                                               }];
    }
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

-(void) handleIncomingMessage:(NSDictionary *) userInfo {
    NSLog(@"Received UserInfo:\n%@", userInfo);
}

#pragma mark - Send Test Message

-(void) sendTestMessage {
#ifdef DEBUG
    NSString *messageId = [[NSDate new] description];
    NSString *gcmId = @"nfzdIh6UcPU:APA91bFFZXoD8ixLqlZJcP3oz3fn2EHLKi_iZ3-cRzJ59_zmNxQjLVwLzx_SyeZld03lVbaUYt8CdDSG5TF2CgZHLrRPbbEs5OVEC_-7Af96eyR9rRKABgTolTRKtjAMC4O5YUrmN3y_";
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              messageId,    @"messageId",
                              gcmId,        @"gcmId",
                              nil];
    [[GCMService sharedInstance] sendMessage:infoDict to:gcmId withId:messageId];
#endif

}

@end
