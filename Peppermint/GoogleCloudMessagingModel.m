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

@implementation GoogleCloudMessagingModel

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
        //init...
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

@end
