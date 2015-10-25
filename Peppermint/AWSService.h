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

#define AWS_API_KEY             @"abc123"

#define BASE_URL                @"https://qdkkavugcd.execute-api.us-west-2.amazonaws.com/prod/v1"
#define ENDPOINT_RECORDER       @"/recorder"
#define ENDPOINT_UPLOADS        @"/uploads"
#define ENDPOINT_RECORD         @"/record"

@interface AWSService : BaseService
@property(strong, nonatomic) NSString *apiKey;

-(void) submitRecorderWithUdid:(NSString*) clientId;
-(void) retrieveSignedURLForContentType:(NSString*) contentType jwt:(NSString*) jwt;
-(void) sendData:(NSData*) data ofContentType:(NSString*) contentType tosignedURL:(NSString*) signedUrl;
-(void) finalizeFileUploadForSignedUrl:(NSString*) signedUrl withJwt:(NSString*) jwt;
@end
