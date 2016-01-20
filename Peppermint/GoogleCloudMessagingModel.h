//
//  GoogleCloudMessagingModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 20/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import <Google/CloudMessaging.h>

@interface GoogleCloudMessagingModel : BaseModel <GCMReceiverDelegate>

@property(nonatomic, readonly, strong) NSString *registrationKey;
@property(nonatomic, readonly, strong) NSString *messageKey;
@property(nonatomic, readonly, strong) NSString *gcmSenderID;
@property(nonatomic, strong) NSDictionary *registrationOptions;
@property(nonatomic, strong) NSString* registrationToken;
@property(nonatomic, readonly, assign) BOOL connectedToGCM;
@property(nonatomic, assign) BOOL subscribedToTopic;
@property(nonatomic, readonly, strong) void (^registrationHandler) (NSString *registrationToken, NSError *error);

+ (instancetype) sharedInstance;
- (void) initGCM;
- (void) connectGCM;
- (void) disconnectGCM;
@end
