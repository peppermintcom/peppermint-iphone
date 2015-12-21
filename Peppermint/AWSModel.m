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
    //Last 5 chrarters are added to be sure about the uniqueness!
    udid = [NSString stringWithFormat:@"%@_%@", udid, [[NSString alloc] randomStringWithLength:5]];
    return udid;
}

-(BOOL) isJWTValid {
    BOOL result = NO;
    jwt = [[A0SimpleKeychain keychain] stringForKey:KEYCHAIN_AWS_JWT];
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
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        [awsService retrieveSignedURLForContentType:_contentType jwt:jwt data:data senderName:peppermintMessageSender.nameSurname senderEmail:peppermintMessageSender.email];
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
        NSLog(@"File upload is completed with signedURL:%@", _signedUrl);
    }
}

SUBSCRIBE(NetworkFailure) {
    if(event.sender == awsService) {
        [self.delegate operationFailure:[event error]];
    }
}

@end
