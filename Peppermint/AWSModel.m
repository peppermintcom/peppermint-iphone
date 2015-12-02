//
//  AWSModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 24/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "AWSModel.h"
#import "A0SimpleKeychain.h"

@implementation AWSModel {
    NSString *jwt;
    AWSService *awsService;
    NSString *_signedUrl;
    NSString *_contentType;
    NSData *_data;
}

-(id) init {
    self = [super init];
    if(self) {
        awsService = [AWSService new];
    }
    return self;
}

-(NSString*) getUniqueClientNumber {
    NSString *udid = nil;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        udid = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    }
    return udid;
}

#pragma mark - Init

-(void) initRecorder {    
    jwt = [[A0SimpleKeychain keychain] stringForKey:KEYCHAIN_AWS_JWT];
    if(jwt.length > 0) {
        [self.delegate recorderInitIsSuccessful];
    } else {
        NSString *clientId = [self getUniqueClientNumber];
        [awsService submitRecorderWithUdid:clientId];
    }
}

SUBSCRIBE(RecorderSubmitSuccessful) {
    jwt = event.jwt;
    [[A0SimpleKeychain keychain] setString:jwt forKey:KEYCHAIN_AWS_JWT];
    [self.delegate recorderInitIsSuccessful];
}

#pragma mark - Upload File

-(void) startToUploadData:(NSData*) data ofType:(NSString*) contentType {
    if(!data || !contentType) {
        NSLog(@"Stopped aws cos the data or content type is supplied!");
    } else {
        _data = data;
        _contentType = contentType;
        [awsService retrieveSignedURLForContentType:_contentType jwt:jwt data:data];
    }
}

SUBSCRIBE(RetrieveSignedUrlSuccessful) {
    if(event.sender == awsService) {
        _signedUrl = event.signedUrl;
        [awsService sendData:_data ofContentType:_contentType tosignedURL:_signedUrl];
        [self.delegate fileUploadCompletedWithPublicUrl:event.short_url];
    }
}

SUBSCRIBE(FileUploadCompleted) {
    if([event.signedUrl isEqualToString:_signedUrl] && event.sender == awsService) {
#warning "finalizeFileUploadForSignedUrl" is deprecated, clean unused code
        //finalizeFileUploadForSignedUrl is deprecated!
        //[awsService finalizeFileUploadForSignedUrl:_signedUrl withJwt:jwt];
    }
}

SUBSCRIBE(FileUploadFinalized) {
    if([event.signedUrl isEqualToString:_signedUrl]
        && event.sender == awsService) {
        NSString *shortUrl = event.shortUrl;
        [self.delegate fileUploadCompletedWithPublicUrl:shortUrl];
    }
}

SUBSCRIBE(NetworkFailure) {
    if(event.sender == awsService) {
        [self.delegate operationFailure:[event error]];
    }
}

@end
