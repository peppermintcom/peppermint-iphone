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

@implementation AWSService

-(id)init {
    self = [super init];
    if(self) {
        self.baseUrl = AWS_BASE_URL;
        self.apiKey = AWS_API_KEY;
    }
    return self;
}

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
                recorderSubmitSuccessful.jwt = recorderResponse.at;
                PUBLISH(recorderSubmitSuccessful);
            }
        }];
        [dataTask resume];
    }
}

-(NSString*) toketTextForJwt:(NSString*) jwt {
    return [NSString stringWithFormat:@"%@ %@",BEARER, jwt];
}

-(void) retrieveSignedURLForContentType:(NSString*) contentType jwt:(NSString*) jwt data:(NSData*)data {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_UPLOADS];
    NSString *tokenText = [self toketTextForJwt:jwt];
    
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    
    UploadsRequest *uploadsRequest = [UploadsRequest new];
    uploadsRequest.content_type = contentType;
    NSDictionary *parameterDictionary = [uploadsRequest toDictionary];
    
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        UploadsResponse *response = [[UploadsResponse alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            [self failureWithOperation:nil andError:error];
        }
        RetrieveSignedUrlSuccessful *retrieveSignedUrlSuccessful = [RetrieveSignedUrlSuccessful new];
        retrieveSignedUrlSuccessful.data = data;
        retrieveSignedUrlSuccessful.signedUrl = response.signed_url;
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
                fileUploadCompleted.signedUrl = signedUrl;
                PUBLISH(fileUploadCompleted);
            }
        }];
        [dataTask resume];
    }
}

-(void) finalizeFileUploadForSignedUrl:(NSString*) signedUrl withJwt:(NSString*) jwt {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, AWS_ENDPOINT_RECORD];
    NSString *tokenText = [self toketTextForJwt:jwt];
    
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestOperationManager.requestSerializer setValue:tokenText forHTTPHeaderField:AUTHORIZATION];
    
    FinalizeUploadRequest *finalizeUploadRequest = [FinalizeUploadRequest new];
    finalizeUploadRequest.signed_url = signedUrl;
    NSDictionary *parameterDictionary = [finalizeUploadRequest toDictionary];
    
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        FinalizeUploadResponse *response = [[FinalizeUploadResponse alloc] initWithDictionary:responseObject error:&error];
        if (error) {
            [self failureWithOperation:nil andError:error];
        }
        FileUploadFinalized *fileUploadFinalized = [FileUploadFinalized new];
        fileUploadFinalized.signedUrl = signedUrl;
        fileUploadFinalized.shortUrl = response.short_url;
        PUBLISH(fileUploadFinalized);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}

@end
