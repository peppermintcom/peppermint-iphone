//
//  WKServerManager.m
//  Peppermint
//
//  Created by Yan Saraev on 11/21/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//
@import UIKit;

#import "MandrillRequest.h"
#import "MandrillMessage.h"
#import "MandrillToObject.h"
#import "PeppermintContact.h"
#import "PeppermintMessageSender.h"

NSString * const PPMMandrillScheme = @"https";
NSString * const PPMMandrillServerURL = @"mandrillapp.com";
NSString * const PPMMandrillVersionAPI = @"api/1.0";

NSString * const PPMMandrillEndPointSend = @"messages/send.json";

#import "WKServerManager.h"

@interface WKServerManager () <NSURLSessionDelegate>

@end

@implementation WKServerManager

+ (WKServerManager*)sharedManager {
    static dispatch_once_t pred;
    static WKServerManager *_sharedManager = nil;
    
    dispatch_once(&pred, ^{
        _sharedManager = [[WKServerManager alloc] init];
    });
    return _sharedManager;
}

- (void)sendFileURL:(NSURL *)fileURL recipient:(PeppermintContact *)recipient {
  if (!fileURL) {
    fileURL = [[NSBundle mainBundle] URLForResource:@"begin_record" withExtension:@"mp3"];
  }
  NSData * data = [NSData dataWithContentsOfURL:fileURL];
  
  MandrillMailAttachment * attachment = [MandrillMailAttachment new];
  attachment.content = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  attachment.type = @"audio/wav";
  attachment.name = @"test.wav";
  
  PeppermintMessageSender * sender = [PeppermintMessageSender sharedInstance];
  
  MandrillToObject * mandrillRecipient = [MandrillToObject new];
  mandrillRecipient.email = recipient.communicationChannelAddress;
  mandrillRecipient.name = recipient.nameSurname;
  mandrillRecipient.type = @"to";
  
  MandrillMessage * message = [MandrillMessage new];
  message.from_email = sender.email;
  message.from_name = sender.nameSurname;
  message.to = [@[mandrillRecipient] mutableCopy];
  message.subject = sender.subject;
  message.attachments = [@[attachment] mutableCopy];
  
  MandrillRequest * request = [MandrillRequest new];
  request.key = MANDRILL_API_KEY;
  request.message = message;
  
  [self sendAudioMessage:[request toDictionary]];
}

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
    if (error) {
      NSLog(@"error: %@", error);
      return;
    }
  }];
  
  [postDataTask resume];
}

+ (NSString *)baseURL {
  NSString * urlFormat = @"%@://%@/%@";
  NSString * baseURLString = [NSString stringWithFormat:urlFormat, PPMMandrillScheme, PPMMandrillServerURL, PPMMandrillVersionAPI];
  return baseURLString;
}


@end
