//
//  AWSService.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "AWSService.h"

#define AUTHORIZATION   @"Authorization"
#define BEARER          @"Bearer"
#define X_API_KEY @"X-Api-Key"

@implementation AWSService

-(id)init {
    self = [super init];
    if(self) {
        self.baseUrl = AWS_BASE_URL;
        self.apiKey = AWS_API_KEY;
    }
    return self;
}

#pragma mark - Recorder

-(void) submitRecorderWithUdid:(NSString*) clientId {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_RECORDER];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    RecorderRequest *recorderRequest = [RecorderRequest new];
    recorderRequest.api_key = self.apiKey;
    Recorder *recorder = [Recorder new];
    recorder.recorder_client_id = clientId;
    recorderRequest.recorder = recorder;
    NSDictionary *parameterDictionary = [recorderRequest toDictionary];
    
    NSError *error;
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameterDictionary error:&error];
    if(error) {
        [self failureDuringRequestCreationWithError:error];
    } else {
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                [self failureWithOperation:nil andError:error];
            } else {
                RecorderResponse *recorderResponse = [[RecorderResponse alloc] initWithDictionary:responseObject error:&error];
                if (error) {
                    [self failureWithOperation:nil andError:error];
                }
                RecorderSubmitSuccessful *recorderSubmitSuccessful = [RecorderSubmitSuccessful new];
                recorderSubmitSuccessful.sender = self;
                recorderSubmitSuccessful.jwt = recorderResponse.at;
                recorderSubmitSuccessful.recorder_client_id = recorderResponse.recorder.recorder_client_id;
                recorderSubmitSuccessful.recorder_key = recorderResponse.recorder.recorder_key;
                recorderSubmitSuccessful.recorder_id = recorderResponse.recorder.recorder_id;
                PUBLISH(recorderSubmitSuccessful);
            }
        }];
        [dataTask resume];
    }
}

-(NSString*) toketTextForJwt:(NSString*) jwt {
    return [NSString stringWithFormat:@"%@ %@",BEARER, jwt];
}

-(void) retrieveSignedURLForContentType:(NSString*) contentType jwt:(NSString*) jwt data:(NSData*)data senderName:(NSString*)senderName senderEmail:(NSString*)senderEmail {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_UPLOADS];
    NSString *tokenText = [self toketTextForJwt:jwt];
    
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    
    UploadsRequest *uploadsRequest = [UploadsRequest new];
    uploadsRequest.content_type = contentType;
    uploadsRequest.sender_name = senderName;
    uploadsRequest.sender_email = senderEmail;
    NSDictionary *parameterDictionary = [uploadsRequest toDictionary];
    
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        UploadsResponse *response = [[UploadsResponse alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            [self failureWithOperation:nil andError:error];
        }
        RetrieveSignedUrlSuccessful *retrieveSignedUrlSuccessful = [RetrieveSignedUrlSuccessful new];
        retrieveSignedUrlSuccessful.sender = self;
        retrieveSignedUrlSuccessful.signedUrl = response.signed_url;
        retrieveSignedUrlSuccessful.canonical_url = response.canonical_url;
        retrieveSignedUrlSuccessful.short_url = response.short_url;
        PUBLISH(retrieveSignedUrlSuccessful);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}

-(void) sendData:(NSData*) data ofContentType:(NSString*) contentType tosignedURL:(NSString*) signedUrl{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSError *error;
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSURLRequest *request = [requestSerializer requestWithMethod:@"PUT" URLString:signedUrl parameters:nil error:&error];
    if(error) {
        [self failureDuringRequestCreationWithError:error];
    } else {
        NSURLSessionDataTask *dataTask = [manager uploadTaskWithRequest:request fromData:data progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                [self failureWithOperation:nil andError:error];
            } else {
                FileUploadCompleted *fileUploadCompleted = [FileUploadCompleted new];
                fileUploadCompleted.sender = self;
                fileUploadCompleted.signedUrl = signedUrl;
                PUBLISH(fileUploadCompleted);
            }
        }];
        [dataTask resume];
    }
}

#pragma mark - Account

-(void) registerAccount:(User*) user {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_ACCOUNTS];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AccountRequest *accountRequest = [AccountRequest new];
    accountRequest.api_key = self.apiKey;
    accountRequest.u = user;
    NSDictionary *parameterDictionary = [accountRequest toDictionary];
    
    NSError *error;
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameterDictionary error:&error];
    if(error) {
        [self failureDuringRequestCreationWithError:error];
    } else {
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if(((NSHTTPURLResponse*)response).statusCode == RESPONSE_CODE_CONFLICT) {
                AccountRegisterConflictTryLogin *accountRegisterConflictTryLogin = [AccountRegisterConflictTryLogin new];
                accountRegisterConflictTryLogin.email = user.email;
                accountRegisterConflictTryLogin.password = user.password;
                PUBLISH(accountRegisterConflictTryLogin);
            }
            else if (error) {
                [self failureWithOperation:nil andError:error];
            } else {
                AccountResponse *accountResponse = [[AccountResponse alloc] initWithDictionary:responseObject error:&error];
                if (error) {
                    [self failureWithOperation:nil andError:error];
                }
                
                AccountRegisterIsSuccessful *accountRegisterIsSuccessful = [AccountRegisterIsSuccessful new];
                accountRegisterIsSuccessful.jwt = accountResponse.at;
                accountRegisterIsSuccessful.user = accountResponse.u;
                PUBLISH(accountRegisterIsSuccessful);
            }
        }];
        [dataTask resume];
    }
}

- (void)checkEmailIsRegistered:(NSString *)email {
  NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_ACCOUNTS];
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  
  User * user = [User new];
  user.email = email;
  
  
  NSDictionary *parameterDictionary = [user toDictionary];
  NSError *error;
  NSMutableURLRequest *request = [[[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameterDictionary error:&error] mutableCopy];
  [request setValue:self.apiKey forHTTPHeaderField:X_API_KEY];
  
  if (error) {
    [self failureDuringRequestCreationWithError:error];
  } else {
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        AccountCheckEmail * checkEmail = [AccountCheckEmail new];
        if(error) {
            [self failureWithOperation:nil andError:error];
        } else {
            NSArray *responseArray = (NSArray*)responseObject;
            if(responseArray.count == 0) {
                checkEmail.isEmailRegistered = NO;
                PUBLISH(checkEmail);
            } else {
                NSDictionary *infoDict = [responseArray firstObject];
                CheckEmailResponse *checkEmailResponse = [[CheckEmailResponse alloc] initWithDictionary:infoDict error:&error];
                if (error) {
                    [self failureWithOperation:nil andError:error];
                } else {
                    checkEmail.isEmailRegistered = YES;
                    checkEmail.isEmailVerified = checkEmailResponse.is_verified;
                    NSLog(@"%@, isVerified:%d", checkEmailResponse.email, checkEmailResponse.is_verified);
                }
                PUBLISH(checkEmail);
            }
        }
    }];
    [dataTask resume];
  }
}

-(void) logUserInWithEmail:(NSString*) email password:(NSString*) password {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_ACCOUNTS_TOKENS];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    
    NSString *authText = [NSString stringWithFormat:@"%@:%@", email, password];
    authText =  [authText base64String];
    authText = [NSString stringWithFormat:@"Basic %@", authText];
    
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestOperationManager.requestSerializer setValue:authText forHTTPHeaderField:AUTHORIZATION];
    
    LoginRequest *loginRequest = [LoginRequest new];
    loginRequest.api_key = self.apiKey;
    NSDictionary *parameterDictionary = [loginRequest toDictionary];
    
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        LoginResponse *loginResponse = [[LoginResponse alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            [self failureWithOperation:nil andError:error];
        }
        AccountLoginIsSuccessful *accountLoginIsSuccessful = [AccountLoginIsSuccessful new];
        accountLoginIsSuccessful.sender = self;
        accountLoginIsSuccessful.jwt = loginResponse.at;
        accountLoginIsSuccessful.user = loginResponse.u;
        PUBLISH(accountLoginIsSuccessful);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}

-(void) resendVerificationEmailForJwt:(NSString*) jwt {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_ACCOUNTS_VERIFY];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    
    NSString *tokenText = [self toketTextForJwt:jwt];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    
    [requestOperationManager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        VerificationEmailSent *verificationEmailSent = [VerificationEmailSent new];
        verificationEmailSent.sender = self;
        verificationEmailSent.jwt = jwt;
        PUBLISH(verificationEmailSent);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}


-(void) refreshAccountWithId:(NSString*) accountId andJwt:(NSString*) jwt {
    NSString *url = [NSString stringWithFormat:@"%@%@%@", self.baseUrl, AWS_ENDPOINT_ACCOUNT_QUERY, accountId];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    
    NSString *tokenText = [self toketTextForJwt:jwt];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    
    [requestOperationManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        User *user = [[User alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            [self failureWithOperation:nil andError:error];
        }
        
        AccountInfoRefreshed *accountInfoRefreshed = [AccountInfoRefreshed new];
        accountInfoRefreshed.user = user;
        PUBLISH(accountInfoRefreshed);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}

-(void) recoverPasswordForEmail:(NSString*) email {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_ACCOUNT_RECOVER];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    RecoverPasswordRequest *recoverPasswordRequest = [RecoverPasswordRequest new];
    recoverPasswordRequest.api_key = self.apiKey;
    recoverPasswordRequest.email = email;
    NSDictionary *parameterDictionary = [recoverPasswordRequest toDictionary];
    
    NSError *error;
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameterDictionary error:&error];
    if(error) {
        [self failureDuringRequestCreationWithError:error];
    } else {
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                [self failureWithOperation:nil andError:error];
            } else {
                AccountPasswordRecovered *accountPasswordRecovered = [AccountPasswordRecovered new];
                accountPasswordRecovered.sender = self;
                PUBLISH(accountPasswordRecovered);
            }
        }];
        [dataTask resume];
    }
}

#pragma mark - InterApp Messaging

- (void) updateGCMRegistrationTokenForRecorderId:(NSString*) recorderId jwt:(NSString*) jwt gcmToken:(NSString*)gcmToken {
    NSParameterAssert(recorderId && jwt && gcmToken);
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@", self.baseUrl, AWS_ENDPOINT_RECORDER_QUERY, recorderId];
    NSString *tokenText = [self toketTextForJwt:jwt];
    
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    [requestOperationManager.requestSerializer setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:X_API_KEY];
    
    Attribute *attribute = [Attribute new];
    attribute.gcm_registration_token = gcmToken;
    
    Data *data = [Data new];
    data.type = TYPE_RECORDERS;
    data.id = recorderId;
    data.attributes = attribute;
    
    RecordersUpdateRequest *recordersUpdateRequest = [RecordersUpdateRequest new];
    recordersUpdateRequest.data = data;
    NSDictionary *parameterDictionary = [recordersUpdateRequest toDictionary];
    
    [requestOperationManager PUT:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        RecordersUpdateCompleted *recordersUpdateCompleted = [RecordersUpdateCompleted new];
        recordersUpdateCompleted.sender =self;
        PUBLISH(recordersUpdateCompleted);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}


-(void) exchangeCredentialsForEmail:(NSString*)email password:(NSString*)password recorderClientId:(NSString*)recorderClientId recorderKey:(NSString*)recorderKey {
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_JWTS];
    NSMutableArray *authArray = [NSMutableArray new];
    if(email.length > 0 && password.length > 0) {
        NSString *authText = [NSString stringWithFormat:@"%@:%@", email, password];
        authText =   [NSString stringWithFormat:@"account=%@", [authText base64String]];
        [authArray addObject:authText];
    }
    if(recorderClientId.length > 0 && password.length > 0) {
        NSString *authText = [NSString stringWithFormat:@"%@:%@", recorderClientId, recorderKey];
        authText = [NSString stringWithFormat:@"recorder=%@", [authText base64String]];
        [authArray addObject:authText];
    }
    
    NSParameterAssert(authArray.count > 0);    
    NSString *authHeader = [NSString stringWithFormat:@"Peppermint %@", [authArray componentsJoinedByString:@", "]];
    
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    [requestOperationManager.requestSerializer setValue:authHeader forHTTPHeaderField:AUTHORIZATION];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:X_API_KEY];
    requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.api+json"];
    
    [requestOperationManager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        JwtsResponse *jwtsResponse = [[JwtsResponse alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            [self failureWithOperation:nil andError:error];
        } else {
            JwtsExchanged *jwtsExchanged = [JwtsExchanged new];
            jwtsExchanged.sender = self;
            jwtsExchanged.commonJwtsToken = jwtsResponse.data.attributes.token;
            PUBLISH(jwtsExchanged);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];    
}

-(void) setUpRecorderWithAccountId:(NSString*)accountId recorderId:(NSString*)recorderId jwt:(NSString*)jwt {
    NSMutableString *url = [NSMutableString stringWithString:self.baseUrl];
    [url appendFormat:AWS_ENDPOINT_SETUP_RECORDER_FORMAT, accountId];
    
    NSString *tokenText = [self toketTextForJwt:jwt];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer new];
    [requestOperationManager.requestSerializer setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:X_API_KEY];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.api+json"];
    
    Data *data = [Data new];
    data.type = TYPE_RECORDERS;
    data.id = recorderId;
    SetUpRecorderRequest *setUpRecorderRequest = [SetUpRecorderRequest new];
    setUpRecorderRequest.data = [NSArray arrayWithObjects:[data toDictionary], nil];
    NSDictionary *parameterDictionary = [setUpRecorderRequest toDictionary];
    
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SetUpAccountWithRecorderCompleted *setUpAccountWithRecorderCompleted = [SetUpAccountWithRecorderCompleted new];
        setUpAccountWithRecorderCompleted.sender = self;
        PUBLISH(setUpAccountWithRecorderCompleted);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}

-(void) sendMessageToRecepientEmail:(NSString*)recepientEmail senderEmail:(NSString*)senderEmail transcriptionUrl:(NSString*) transcriptionUrl audioUrl:(NSString*)audioUrl jwt:(NSString*) jwt {
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_MESSAGES];
    NSString *tokenText = [self toketTextForJwt:jwt];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer new];
    [requestOperationManager.requestSerializer setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:X_API_KEY];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.api+json"];
    
    Attribute *attribute = [Attribute new];
    attribute.transcription_url = transcriptionUrl;
    attribute.audio_url = audioUrl;
    attribute.sender_email = senderEmail;
    attribute.recipient_email = recepientEmail;
    
    Data *data = [Data new];
    data.type = TYPE_MESSAGES;
    data.attributes = attribute;
    
    MessageRequest *messageRequest = [MessageRequest new];
    messageRequest.data = data;
    NSDictionary *parameterDictionary = [messageRequest toDictionary];
    
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Message is sent!!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:operation andError:error];
    }];
}

@end
