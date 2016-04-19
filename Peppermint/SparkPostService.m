//
//  SparkPostService.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "SparkPostService.h"

#define AUTHORIZATION   @"Authorization"

@implementation SparkPostService

-(id)init {
    self = [super init];
    if(self) {
        self.baseUrl = SPK_BASE_URL;
        self.apiKey = SPK_IOS_API_KEY;
    }
    return self;
}

-(void) sendMessage:(SparkPostRequest*) message {
    NSString *url = [NSString stringWithFormat:@"%@%@"
                     ,self.baseUrl
                     ,SPK_ENDPOINT_IOS_TEMPLATE];
    
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:AUTHORIZATION];
    NSDictionary *parameterDictionary = [NSDictionary new];
    
    [requestOperationManager GET:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        SparkPostTemplatesResponse *sparkPostTemplatesResponse = [[SparkPostTemplatesResponse alloc]
                                                                  initWithDictionary:responseObject error:&error];
        if(error) {
            [self failureDuringJSONCastWithError:error];
        } else {
            message.content.html = sparkPostTemplatesResponse.results.content.html;
            message.content.text = sparkPostTemplatesResponse.results.content.text;
            [self triggerSendingProcess:message];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}

-(void) triggerSendingProcess:(SparkPostRequest*) message {
    NSString *url = [NSString stringWithFormat:@"%@%@%@"
                     ,self.baseUrl
                     ,SPK_ENDPOINT_TRANSMISSION
                     ,SPK_RECIPIENT_LIMIT];
    AFHTTPRequestOperationManager *requestOperationManager = [[AFHTTPRequestOperationManager alloc]
                                                              initWithBaseURL:[NSURL URLWithString:url]];
    requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestOperationManager.requestSerializer setValue:self.apiKey forHTTPHeaderField:AUTHORIZATION];
    NSDictionary *parameterDictionary = [message toDictionary];    
    [requestOperationManager POST:url parameters:parameterDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MailClientMesssageSent *sparkPostMesssageSent = [MailClientMesssageSent new];
        sparkPostMesssageSent.sender = self;
        PUBLISH(sparkPostMesssageSent);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:nil andError:error];
    }];
}

@end