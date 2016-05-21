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
#define X_API_KEY       @"X-Api-Key"

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
    
    NSDictionary *parameterDictionary = [NSDictionary new];
    NSURLRequest *request = [requestSerializer requestWithMethod:@"PUT" URLString:signedUrl parameters:parameterDictionary error:&error];
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
    requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                                         @"application/vnd.api+json",
                                                                         @"application/json",
                                                                         @"text/plain",
                                                                         nil];
    
    NSDictionary *parameterDictionary = [NSDictionary new];
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        VerificationEmailSent *verificationEmailSent = [VerificationEmailSent new];
        verificationEmailSent.sender = self;
        verificationEmailSent.jwt = jwt;
        PUBLISH(verificationEmailSent);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(operation.response.statusCode / 100 == 4) { //4XX errors mean hard bounce,soft bounce or spam...
            error = [NSError errorWithDomain:DOMAIN_MANDRILL code:-1 userInfo:error.userInfo];
        }
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
    
    NSDictionary *parameterDictionary = [NSDictionary new];
    [requestOperationManager GET:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        recordersUpdateCompleted.gcmToken = gcmToken;
        PUBLISH(recordersUpdateCompleted);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}


-(void) exchangeCredentialsWithPrefix:(NSString*)prefix forEmail:(NSString*)email password:(NSString*)password recorderClientId:(NSString*)recorderClientId recorderKey:(NSString*)recorderKey {
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_JWTS];
    NSMutableArray *authArray = [NSMutableArray new];
    if(email.length > 0 && password.length > 0) {
        NSString *authText = [NSString stringWithFormat:@"%@:%@", email, password];
        authText =   [NSString stringWithFormat:@"%@=%@", prefix, [authText base64String]];
        [authArray addObject:authText];
    }
    if(recorderClientId.length > 0 && recorderKey.length > 0) {
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
    [requestOperationManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.api+json"];
    
    NSDictionary *parameterDictionary = [NSDictionary new];
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        JwtsResponse *jwtsResponse = [[JwtsResponse alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            [self failureWithOperation:nil andError:error];
        } else {
            
#warning "Refactor code to take account Id from JwtsResponse class"
            NSString *accountId = [[[[[responseObject valueForKey:@"data"]
                                      valueForKey:@"relationships"]
                                     valueForKey:@"account"]
                                    valueForKey:@"data"]
                                   valueForKey:@"id"];
            
            JwtsExchanged *jwtsExchanged = [JwtsExchanged new];
            jwtsExchanged.sender = self;
            jwtsExchanged.accountId = accountId;
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

-(void)unlinkRecorder:(NSString*)recorderId fromAccount:(NSString*) accountId withJwt:(NSString*)recorderJwt {
    NSString *servicePath = [NSString stringWithFormat:AWS_ENDPOINT_ACCOUNTS_DELETE_RECORDER, accountId, recorderId];
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, servicePath];
    
    NSString *tokenText = [self toketTextForJwt:recorderJwt];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer new];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:X_API_KEY];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    
    NSDictionary *parameterDictionary = [NSDictionary new];
    [requestOperationManager DELETE:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Recorder is un-linked from Account");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Message could not be sent!!");
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
        InterAppMessageProcessCompleted *interAppMessageProcessCompleted = [InterAppMessageProcessCompleted new];
        interAppMessageProcessCompleted.sender = self;
        interAppMessageProcessCompleted.error = nil;
        PUBLISH(interAppMessageProcessCompleted);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(operation.response.statusCode == RESPONSE_CODE_NOT_FOUND) {
            //User is not available to get inter-app messaging
            InterAppMessageProcessCompleted *interAppMessageProcessCompleted = [InterAppMessageProcessCompleted new];
            interAppMessageProcessCompleted.sender = self;
            interAppMessageProcessCompleted.error = error;
            PUBLISH(interAppMessageProcessCompleted);
        } else if (operation.response.statusCode == RESPONSE_CODE_UNAUTHORIZED) {
            UnauthorizedResponse *unauthorizedResponse = [UnauthorizedResponse new];
            unauthorizedResponse.sender = self;
            PUBLISH(unauthorizedResponse);
        } else if (error) {
            [self failureWithOperation:operation andError:error];
        } else {
            NSLog(@"The situation is not handleable!");
        }
    }];
}

-(void) getMessagesForAccountId:(NSString*) accountId jwt:(NSString*)jwt nextUrl:(NSString*)url order:(NSString*)orderText sinceDate:(NSDate*)sinceDate untilDate:(NSDate*)untilDate recipient:(BOOL)isForRecipient  {

    NSDictionary *parameterDictionary = [NSDictionary new];
    if(!url) {
        NSLog(@"Querying for %@ | until:%@ <-> since:%@", (isForRecipient ? @"Recipient" : @"Sender"), untilDate, sinceDate );
        url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_MESSAGES];
        MessageGetRequest *messageGetRequest = [MessageGetRequest new];
        if(isForRecipient) {
            messageGetRequest.recipient = accountId;
        } else {
            messageGetRequest.sender = accountId;
        }
        messageGetRequest.order = orderText;
        [messageGetRequest setSinceDate:sinceDate];
        [messageGetRequest setUntilDate:untilDate];
        parameterDictionary = [messageGetRequest toDictionary];
    } else {
        NSLog(@"Making a next %@ qury.|updated until:%@ <-> since:%@", (isForRecipient ? @"Recipient" : @"Sender"), untilDate, sinceDate );
    }
    
    NSString *tokenText = [self toketTextForJwt:jwt];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer new];
    [requestOperationManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:X_API_KEY];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.api+json"];

    [requestOperationManager GET:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        MessageGetResponse *messageGetResponse = [[MessageGetResponse alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            [self failureWithOperation:nil andError:error];
        } else {
            GetMessagesAreSuccessful *getMessagesAreSuccessful = [GetMessagesAreSuccessful new];
            getMessagesAreSuccessful.sender = self;
            getMessagesAreSuccessful.dataOfMessagesArray = messageGetResponse.data;
            getMessagesAreSuccessful.existsMoreMessages = (messageGetResponse.links.next != nil);
            getMessagesAreSuccessful.nextUrl = messageGetResponse.links.next;
            getMessagesAreSuccessful.isForRecipient = isForRecipient;
            NSLog(@"Received %d messages from API", messageGetResponse.data.count);
            PUBLISH(getMessagesAreSuccessful);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:operation andError:error];
    }];
}

-(void) markMessageAsReadWithJwt:(NSString*)jwt messageId:(NSString*)messageId {
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_READS];
    NSString *tokenText = [self toketTextForJwt:jwt];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer new];
    [requestOperationManager.requestSerializer setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:X_API_KEY];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.api+json"];
    
    Data *data = [Data new];
    data.type = TYPE_READS;
    data.id = messageId;
    
    MessageRequest *messageRequest = [MessageRequest new];
    messageRequest.data = data;
    NSDictionary *parameterDictionary = [messageRequest toDictionary];
    
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Message with id:%@ is marked as read!", messageId);
        MessageIsMarkedAsRead *messageIsMarkedAsRead = [MessageIsMarkedAsRead new];
        messageIsMarkedAsRead.sender = self;
        PUBLISH(messageIsMarkedAsRead);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //[self failureWithOperation:operation andError:error];
        NSLog(@"Message with id:%@ could not be marked as read!", messageId);
    }];
}

-(void) saveTranscriptionWithJwt:(NSString*)jwt audioUrl:(NSString*)audioUrl language:(NSString*)language transcriptionText:(NSString*)transcriptionText confidence:(NSNumber*) confidence {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_TRANSCRIPTIONS];
    NSString *tokenText = [self toketTextForJwt:jwt];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer new];
    [requestOperationManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:X_API_KEY];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    TranscriptionsRequest *transcriptionsRequest = [TranscriptionsRequest new];
    transcriptionsRequest.audio_url = audioUrl;
    transcriptionsRequest.language = language;
    transcriptionsRequest.text = transcriptionText;
    transcriptionsRequest.confidence = confidence;
    NSDictionary *parameterDictionary = [transcriptionsRequest toDictionary];
    
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Transcription is saved");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Transcription error");
        [self failureWithOperation:operation andError:error];
    }];
}

@end
