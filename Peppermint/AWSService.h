//
//  AWSService.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseService.h"
#import "RecorderRequest.h"
#import "RecorderResponse.h"
#import "UploadsRequest.h"
#import "UploadsResponse.h"
#import "FinalizeUploadRequest.h"
#import "FinalizeUploadResponse.h"
#import "AccountRequest.h"
#import "AccountResponse.h"
#import "LoginRequest.h"
#import "LoginResponse.h"
#import "CheckEmailResponse.h"
#import "RecoverPasswordRequest.h"
#import "RecordersUpdateRequest.h"
#import "JwtsResponse.h"
#import "SetUpRecorderRequest.h"
#import "MessageRequest.h"


#warning "Dont forget to fix below lines about API key!!!"

/*
 DEVELOPMENT:
 iOS :          "ios-dev"
 Android :      "android-dev"
 
 PROD
 iOS :          "AiaWKSSoYgNv5WdLFMqkh1j7TgKq7evmQlOiFNAQxkXL7GrIHVqQJw"
 Android :      "la8H4E6Iw5teA6nelVZWgZWqVJh7kWc6Gn1rj21hsYcTP7y7JAmDDQ"
 
*/

#ifdef DEBUG
#define AWS_API_KEY                     @"ios-dev"
#else
#warning "Added for test purposes, dont forget to open again!"
#define AWS_API_KEY                     @"ios-dev"
#endif

#define AWS_BASE_URL                    @"https://qdkkavugcd.execute-api.us-west-2.amazonaws.com/prod/v1"
#define AWS_ENDPOINT_RECORDER           @"/recorder"
#define AWS_ENDPOINT_UPLOADS            @"/uploads"
#define AWS_ENDPOINT_ACCOUNTS           @"/accounts"
#define AWS_ENDPOINT_ACCOUNTS_TOKENS    @"/accounts/tokens"
#define AWS_ENDPOINT_ACCOUNTS_VERIFY    @"/accounts/verify"
#define AWS_ENDPOINT_ACCOUNT_QUERY      @"/accounts/"    // Add account id to the path. For example : /accounts/{account_id}
#define AWS_ENDPOINT_ACCOUNT_RECOVER    @"/accounts/recover"
#define AWS_ENDPOINT_RECORDER_QUERY     @"/recorders/"   //Add recorder id to the path. For example : /recorders/{recorder_id}
#define AWS_ENDPOINT_JWTS               @"/jwts"
#define AWS_ENDPOINT_SETUP_RECORDER_FORMAT  @"/accounts/%@/relationships/receivers" // SetUp recorder format
#define AWS_ENDPOINT_MESSAGES           @"/messages"
#define AWS_ENDPOINT_ACCOUNTS_DELETE_RECORDER   @"/accounts/%@/relationships/receivers/%@"  //Delete recorder from account format

#define RESPONSE_CODE_CONFLICT      409

@interface AWSService : BaseService
@property(strong, nonatomic) NSString *apiKey;

-(void) submitRecorderWithUdid:(NSString*) clientId;
-(void) retrieveSignedURLForContentType:(NSString*) contentType jwt:(NSString*) jwt data:(NSData*)data senderName:(NSString*)senderName senderEmail:(NSString*)senderEmail;
-(void) sendData:(NSData*) data ofContentType:(NSString*) contentType tosignedURL:(NSString*) signedUrl;

-(void) registerAccount:(User*) user;
-(void) logUserInWithEmail:(NSString*) email password:(NSString*) password;
-(void) resendVerificationEmailForJwt:(NSString*) jwt;
-(void) refreshAccountWithId:(NSString*) accountId andJwt:(NSString*) jwt;
-(void) checkEmailIsRegistered:(NSString *)email;
-(void) recoverPasswordForEmail:(NSString*) email;

-(void) updateGCMRegistrationTokenForRecorderId:(NSString*) recorderId jwt:(NSString*) jwt gcmToken:(NSString*)gcmToken;
-(void) exchangeCredentialsWithPrefix:(NSString*)prefix forEmail:(NSString*)email password:(NSString*)password recorderClientId:(NSString*)recorderClientId recorderKey:(NSString*)recorderKey;
-(void) setUpRecorderWithAccountId:(NSString*)accountId recorderId:(NSString*)recorderId jwt:(NSString*)jwt;
-(void)unlinkRecorder:(NSString*)recorderId fromAccount:(NSString*) accountId withJwt:(NSString*)recorderJwt;
-(void) sendMessageToRecepientEmail:(NSString*)recepientEmail senderEmail:(NSString*)senderEmail transcriptionUrl:(NSString*) transcriptionUrl audioUrl:(NSString*)audioUrl jwt:(NSString*) jwt;

@end
