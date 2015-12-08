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

#define AWS_API_KEY                     @"abc123"

#define AWS_BASE_URL                    @"https://qdkkavugcd.execute-api.us-west-2.amazonaws.com/prod/v1"
#define AWS_ENDPOINT_RECORDER           @"/recorder"
#define AWS_ENDPOINT_UPLOADS            @"/uploads"
#warning "AWS_ENDPOINT_RECORD is deprecated, remove it!"
#define AWS_ENDPOINT_RECORD           @"/record" //Deprecated!
#define AWS_ENDPOINT_ACCOUNTS           @"/accounts"
#define AWS_ENDPOINT_ACCOUNTS_TOKENS    @"/accounts/tokens"
#define AWS_ENDPOINT_ACCOUNTS_VERIFY    @"/accounts/verify"
#define AWS_ENDPOINT_ACCOUNT_QUERY      @"/accounts/"    // Add account id to the path. For example : /accounts/{account_id}

#define RESPONSE_CODE_CONFLICT      409

@interface AWSService : BaseService
@property(strong, nonatomic) NSString *apiKey;

-(void) submitRecorderWithUdid:(NSString*) clientId;
-(void) retrieveSignedURLForContentType:(NSString*) contentType jwt:(NSString*) jwt data:(NSData*)data;
-(void) sendData:(NSData*) data ofContentType:(NSString*) contentType tosignedURL:(NSString*) signedUrl;
-(void) finalizeFileUploadForSignedUrl:(NSString*) signedUrl withJwt:(NSString*) jwt;

-(void) registerAccount:(User*) user;
-(void) logUserInWithEmail:(NSString*) email password:(NSString*) password;
-(void) resendVerificationEmailForJwt:(NSString*) jwt;
-(void) refreshAccountWithId:(NSString*) accountId andJwt:(NSString*) jwt;
-(void) checkEmailIsRegistered:(NSString *)email;

@end
