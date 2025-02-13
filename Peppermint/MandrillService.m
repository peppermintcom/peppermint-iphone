//
//  MandrillService.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "MandrillService.h"

@implementation MandrillService

-(id)init {
    self = [super init];
    if(self) {
        self.baseUrl = MND_BASE_URL;
        self.apiKey = MANDRILL_API_KEY;
    }
    return self;
}

-(void) getInformation
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, MND_ENDPOINT_INFO];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    MandrillRequest *request = [MandrillRequest new];
    request.key = self.apiKey;
    NSDictionary *parameters = request.toDictionary;
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        /*
        NSError *error;
        MandrillInformationResponse *informationResponse = [[MandrillInformationResponse alloc] initWithDictionary:responseObject error:&error];
        if(error) {
            [self failureDuringJSONCastWithError:error];
        }
        informationResponse = nil;
         */
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failureWithOperation:operation andError:error];
    }];
}

-(void) sendMessage:(MandrillMessage*) message {
    [self sendMessage:message templateName:nil];
}

-(void) sendMessage:(MandrillMessage*) message templateName:(NSString*)templateName {
    
    NSString *endPoint = templateName == nil ? MND_ENDPOINT_SEND_MAIL : MND_ENDPOINT_SEND_TEMPLATE_MAIL;
    NSString *url = [NSString stringWithFormat:@"%@%@", self.baseUrl, endPoint];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    MandrillRequest *mandrillRequest = [MandrillRequest new];
    mandrillRequest.key = self.apiKey;
    mandrillRequest.message = message;
    if(!mandrillRequest.template_content) {
        mandrillRequest.template_content = [NSMutableArray<MandrillNameContentPair> new];
    }
    if(templateName) {
        mandrillRequest.template_name = templateName;
    }
    NSDictionary *parameterDictionary = [mandrillRequest toDictionary];

    NSError *error;
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameterDictionary error:&error];
    if(error) {
        [self failureDuringRequestCreationWithError:error];
    } else {
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                [self failureWithOperation:nil andError:error];
            } else {
                MailClientMesssageSent *mandrillMesssageSent = [MailClientMesssageSent new];
                mandrillMesssageSent.sender = self;
                PUBLISH(mandrillMesssageSent);
            }
        }];
        [dataTask resume];
    }
}

@end