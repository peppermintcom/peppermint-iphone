//
//  Events.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MandrillMessage.h"
#import "User.h"

@interface BaseEvent : NSObject
@property (nonatomic) id sender;
@end

@interface NetworkFailure : BaseEvent
@property(nonatomic) NSError *error;
@end

//Needs a unique handler
@interface MailClientMesssageSent : BaseEvent
@end

@interface ApplicationWillResignActive : BaseEvent
@end

@interface ApplicationDidEnterBackground : BaseEvent
@end

@interface ApplicationWillEnterForeground : BaseEvent
@end

@interface ApplicationDidBecomeActive : BaseEvent
@end

@interface RecorderSubmitSuccessful : BaseEvent
@property (strong, nonatomic) NSString *jwt;
@property (strong, nonatomic) NSString *recorder_client_id;
@property (strong, nonatomic) NSString *recorder_key;
@property (strong, nonatomic) NSString *recorder_id;
@end

//Needs a unique handler
@interface RetrieveSignedUrlSuccessful : BaseEvent
@property (strong, nonatomic) NSString *signedUrl;
@property (strong, nonatomic) NSString *canonical_url;
@property (strong, nonatomic) NSString *short_url;
//@property (strong, nonatomic) NSData* data;
@end

//Needs a unique handler
@interface FileUploadCompleted : BaseEvent
@property (strong, nonatomic) NSString *signedUrl;
@end

@interface AccountRegisterIsSuccessful : BaseEvent
@property (strong, nonatomic) NSString *jwt;
@property (strong, nonatomic) User *user;
@end

@interface AccountLoginIsSuccessful : BaseEvent
@property (strong, nonatomic) NSString *jwt;
@property (strong, nonatomic) User *user;
@end

@interface AccountRegisterConflictTryLogin : BaseEvent
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@end

@interface AccountCheckEmail : BaseEvent
@property (assign, nonatomic) BOOL isEmailRegistered;
@property (assign, nonatomic) BOOL isEmailVerified;
@end

@interface VerificationEmailSent : BaseEvent
@property (strong, nonatomic) NSString* jwt;
@end

@interface AccountPasswordRecovered : BaseEvent
@end

@interface AccountInfoRefreshed : BaseEvent
@property (strong, nonatomic) User *user;
@end

@interface SyncGoogleContactsSuccess : BaseEvent
@end

@interface AttachSuccess : BaseEvent
@end

@interface DetachSuccess : BaseEvent
@end

@interface ReplyContactIsAdded : BaseEvent
@end

@interface MessageSendingStatusIsUpdated : BaseEvent
@end

@interface RecordersUpdateCompleted : BaseEvent
@property (strong, nonatomic) NSString *gcmToken;
@end

@interface JwtsExchanged : BaseEvent
@property (strong, nonatomic) NSString *commonJwtsToken;
@property (strong, nonatomic) NSString *accountId;
@end

@interface SetUpAccountWithRecorderCompleted : BaseEvent
@end

@interface NewUserLoggedIn : BaseEvent
@end

@interface UserLoggedOut : BaseEvent
@end

@interface StopAllPlayingMessages : BaseEvent
@end

@interface GetMessagesAreSuccessful : BaseEvent
@property (assign, nonatomic) BOOL isForRecipient;
@property (strong, nonatomic) NSArray* dataOfMessagesArray;
@property (assign, nonatomic) BOOL existsMoreMessages;
@property (assign, nonatomic) NSString* nextUrl;
@end

@interface RefreshIncomingMessagesCompletedWithSuccess : BaseEvent
@property (strong, nonatomic) NSArray* peppermintChatEntryNewMesssagesArray;
@property (strong, nonatomic) NSArray* peppermintChatEntryAllMesssagesArray;
@end

@interface AccountIdIsUpdated : BaseEvent
@end

@interface MessageIsMarkedAsRead : BaseEvent
@end

@interface ProximitySensorValueIsUpdated : BaseEvent
@property (nonatomic, assign) BOOL isDeviceCloseToUser;
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;
@property (nonatomic, assign) BOOL isDeviceOrientationCorrectOnEar;
@end

@interface ShakeGestureOccured : BaseEvent
@end

@interface AudioSessionInterruptionOccured : BaseEvent
@property (nonatomic, assign) BOOL hasInterruptionBegan;
@end

@interface InterAppMessageProcessCompleted : BaseEvent
@property (strong, nonatomic) NSError *error;
@end

@interface UnauthorizedResponse : BaseEvent
@end
