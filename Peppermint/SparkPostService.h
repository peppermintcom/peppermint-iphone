//
//  SparkPostService.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseService.h"
#import "SparkPostRequest.h"
#import "SparkPostTemplatesResponse.h"

//REMOTE ENDPOINT SETINGS
#define SPK_IOS_API_KEY         @"762d6093cf3204fb0c1a24f392019a7942b0665f"
#define CHROME_API_KEY          @"74d47793522fa8f719c94d6274d8654d8be93817"

#define SPK_BASE_URL                @"https://api.sparkpost.com/api/v1"
#define SPK_ENDPOINT_IOS_TEMPLATE   @"/templates/audio-mail-template?draft=false"
#define SPK_ENDPOINT_TRANSMISSION   @"/transmissions"
#define SPK_RECIPIENT_LIMIT         @"?num_rcpt_errors=3"


@interface SparkPostService : BaseService
@property(strong, nonatomic) NSString *apiKey;

-(void) sendMessage:(SparkPostRequest*) message;

@end
