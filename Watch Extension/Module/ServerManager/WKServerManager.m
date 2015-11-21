//
//  WKServerManager.m
//  Peppermint
//
//  Created by Yan Saraev on 11/21/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//
@import UIKit;

NSString * const PPMMandrillScheme = @"https";
NSString * const PPMMandrillServerURL = @"mandrillapp.com";
NSString * const PPMMandrillVersionAPI = @"api/1.0";

NSString * const PPMMandrillEndPointSend = @"messages/send.json";

#import "WKServerManager.h"

@interface WKServerManager () <NSURLSessionDelegate>

@end

@implementation WKServerManager

- (void)sendAudioMessage:(NSDictionary *)parameters {
  
  NSString * urlFormat = @"%@/%@";
  NSString * urlString = [NSString stringWithFormat:urlFormat,[WKServerManager baseURL], PPMMandrillEndPointSend];
  NSURL * url = [NSURL URLWithString:urlString];
  
  NSError *error;
  
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:60.0];
  
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  
  [request setHTTPMethod:@"POST"];
  NSDictionary *mapData = parameters;
  NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
  [request setHTTPBody:postData];
  
  NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
  }];
  
  [postDataTask resume];
}

+ (NSString *)baseURL {
  NSString * urlFormat = @"%@://%@/%@";
  NSString * baseURLString = [NSString stringWithFormat:urlFormat, PPMMandrillScheme, PPMMandrillServerURL, PPMMandrillVersionAPI];
  return baseURLString;
}


@end
