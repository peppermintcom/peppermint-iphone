//
//  MandrillService.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseService.h"
#import "MandrillInformationResponse.h"
#import "MandrillRequest.h"

//REMOTE ENDPOINT SETINGS

#define MND_BASE_URL            @"https://mandrillapp.com/api/1.0"
#define MND_ENDPOINT_INFO       @"/users/info.json"

#define MND_ENDPOINT_SEND_MAIL              @"/messages/send.json"
#define MND_ENDPOINT_SEND_TEMPLATE_MAIL     @"/messages/send-template.json"

@interface MandrillService : BaseService
@property(strong, nonatomic) NSString *apiKey;

-(void) getInformation;
-(void) sendMessage:(MandrillMessage*) message;
-(void) sendMessage:(MandrillMessage*) message templateName:(NSString*)templateName;

@end