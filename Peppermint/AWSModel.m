//
//  AWSModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "AWSModel.h"
#import "A0SimpleKeychain.h"
#import "JwtInformation.h"
#import "PeppermintMessageSender.h"
#import "GoogleCloudMessagingModel.h"
#import "ChatEntryModel.h"

#define AUTH_FACEBOOK   @"facebook"
#define AUTH_GOOGLE     @"google"
#define AUTH_PEPPERMINT @"account"

@implementation AWSModel {
    NSString *jwt;
    AWSService *awsService;
    NSString *_signedUrl;
    NSString *_contentType;
    NSData *_data;
    BOOL isSetUpAccountAttemptActive;
}

-(id) init {
    self = [super init];
    if(self) {
        awsService = [AWSService new];
        isSetUpAccountAttemptActive = NO;
    }
    return self;
}

-(NSString*) getUniqueClientNumber {
    NSString *udid = nil;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {        
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        udid = [NSString stringWithFormat:@"%@", (__bridge NSString *)string];
        CFRelease(string);
    }
    
    //Last 5 chrarters are added to be sure about the uniqueness!
    udid = [NSString stringWithFormat:@"%@_%@_%f", udid, [[NSString alloc] randomStringWithLength:5], [NSDate new].timeIntervalSince1970];
    return udid;
}

-(BOOL) isJWTValid {
    BOOL result = NO;
    jwt = [PeppermintMessageSender sharedInstance].recorderJwt;
    JwtInformation *jwtInformation = [JwtInformation instancewithJwt:jwt andError:nil];
    if(jwtInformation != nil) {
        //Future time is set to 2 days
        NSDate *bufferedFutureTime = [[NSDate date] dateByAddingTimeInterval:(2*24*60*60)];
        result = (jwtInformation.exp > bufferedFutureTime.timeIntervalSince1970);
    }
    return result;
}

#pragma mark - Init

-(void) initRecorder {
    if([self isJWTValid]) {
        [self.delegate recorderInitIsSuccessful];
    } else {
        NSString *clientId = [self getUniqueClientNumber];
        [awsService submitRecorderWithUdid:clientId];
    }
}

SUBSCRIBE(RecorderSubmitSuccessful) {
    if(event.sender == awsService) {
        jwt = event.jwt;
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        peppermintMessageSender.recorderJwt = jwt;
        peppermintMessageSender.recorderId = event.recorder_id;
        peppermintMessageSender.recorderClientId = event.recorder_client_id;
        peppermintMessageSender.recorderKey = event.recorder_key;
        [peppermintMessageSender save];
        [self.delegate recorderInitIsSuccessful];
        [self tryToUpdateGCMRegistrationToken];
    }
}

#pragma mark - Upload File

-(void) startToUploadData:(NSData*) data ofType:(NSString*) contentType {
    if(!data || !contentType) {
        NSLog(@"Stopped aws cos the data or content type is supplied!");
    } else {
        _data = data;
        _contentType = contentType;
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        [awsService retrieveSignedURLForContentType:_contentType jwt:jwt data:data senderName:peppermintMessageSender.nameSurname senderEmail:peppermintMessageSender.email];
    }
}

SUBSCRIBE(RetrieveSignedUrlSuccessful) {
    if(event.sender == awsService) {
        _signedUrl = event.signedUrl;
        [awsService sendData:_data ofContentType:_contentType tosignedURL:_signedUrl];
        [self.delegate fileUploadCompletedWithPublicUrl:event.short_url canonicalUrl:event.canonical_url];
    }
}

SUBSCRIBE(FileUploadCompleted) {
    if([event.signedUrl isEqualToString:_signedUrl] && event.sender == awsService) {
        //NSLog(@"File upload is completed with signedURL:%@", _signedUrl);
    }
}

SUBSCRIBE(NetworkFailure) {
    if(event.sender == awsService) {
        isSetUpAccountAttemptActive = NO;
        [self.delegate operationFailure:[event error]];
    }
}

#pragma mark - Update GCM Registration Token

- (void) tryToUpdateGCMRegistrationToken {
    NSString *gcmToken = [GoogleCloudMessagingModel sharedInstance].registrationToken;
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    if (gcmToken == nil || gcmToken.length == 0) {
        NSLog(@"gcmToken is not defined yet!");
    } else if (peppermintMessageSender.recorderId.length == 0 || peppermintMessageSender.recorderJwt.length == 0) {
        NSLog(@"Recorder is not inited yet!");
    } else {
        [awsService updateGCMRegistrationTokenForRecorderId:peppermintMessageSender.recorderId
                                                        jwt:peppermintMessageSender.recorderJwt
                                                   gcmToken:gcmToken];
    }
}

SUBSCRIBE(RecordersUpdateCompleted) {
    if(event.sender == awsService) {
        NSLog(@"GCM Registration token is saved to server!!");
        [PeppermintMessageSender sharedInstance].gcmToken = event.gcmToken;
        [[PeppermintMessageSender sharedInstance] save];
    }
}

#pragma mark - Set Up Recorder With Account

- (void) tryToSetUpAccountWithRecorder {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    
    if(!isSetUpAccountAttemptActive) {
        if(peppermintMessageSender.email.length > 0
           && peppermintMessageSender.recorderClientId.length>0 && peppermintMessageSender.recorderKey.length > 0) {
            isSetUpAccountAttemptActive = YES;
            
            NSString *prefix;
            NSString *password;
            if (peppermintMessageSender.loginSource == LOGINSOURCE_FACEBOOK) {
                prefix = AUTH_FACEBOOK;
                password = peppermintMessageSender.password;
            } else if (peppermintMessageSender.loginSource == LOGINSOURCE_GOOGLE) {
                prefix = AUTH_GOOGLE;
                password = peppermintMessageSender.password;
            } else if (peppermintMessageSender.loginSource == LOGINSOURCE_PEPPERMINT) {
                prefix = AUTH_PEPPERMINT;
                password = peppermintMessageSender.password;
            }
            
            [awsService exchangeCredentialsWithPrefix:prefix
                                             forEmail:peppermintMessageSender.email
                                           password:password
                                   recorderClientId:peppermintMessageSender.recorderClientId
                                        recorderKey:peppermintMessageSender.recorderKey];
        } else {
            NSLog(@"Could not setup recorder with account. Not enough parameter!");
        }
    } else {
        NSLog(@"A service call is already active. Not calling again!");
    }
}

SUBSCRIBE(JwtsExchanged) {
    if(event.sender == awsService) {
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        NSString *accountId = event.accountId;
        NSString *recorderId = peppermintMessageSender.recorderId;
        peppermintMessageSender.exchangedJwt = event.commonJwtsToken;
        peppermintMessageSender.accountId = event.accountId;
        [peppermintMessageSender save];
        PUBLISH([AccountIdIsUpdated new]);
        [awsService setUpRecorderWithAccountId:accountId recorderId:recorderId jwt:event.commonJwtsToken];
    }
}

SUBSCRIBE(SetUpAccountWithRecorderCompleted) {
    if(event.sender == awsService) {
        isSetUpAccountAttemptActive = NO;
        [PeppermintMessageSender sharedInstance].isAccountSetUpWithRecorder = YES;
        [[PeppermintMessageSender sharedInstance] save];
        NSLog(@"SetUpAccountWithRecorderCompleted");
        
#ifdef DEBUG
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Success"
                                        message:@"SetUpAccountWithRecorderCompleted, now you can receive remote notifications!"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        });
#endif
        
    }
}

#pragma mark - Send Inter App Message

-(void) sendInterAppMessageTo:(NSString*)toEmail from:(NSString*)fromEmail withTranscriptionUrl:(NSString*)transcriptionUrl audioUrl:(NSString*)audioUrl {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    [awsService sendMessageToRecepientEmail:toEmail
                                senderEmail:fromEmail
                           transcriptionUrl:transcriptionUrl
                                   audioUrl:audioUrl
                                        jwt:peppermintMessageSender.exchangedJwt];
}

SUBSCRIBE(InterAppMessageProcessCompleted) {
    if(event.sender == awsService ) {
        NSError *error = event.error;
        if(!error && [self.delegate respondsToSelector:@selector(sendInterAppMessageIsCompletedWithSuccess)]) {
            [self.delegate sendInterAppMessageIsCompletedWithSuccess];
        } else if ([self.delegate respondsToSelector:@selector(sendInterAppMessageIsCompletedWithError:)]) {
            [self.delegate sendInterAppMessageIsCompletedWithError:error];
        }
    }
}

@end
