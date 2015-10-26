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

//#define MANDRILL_API_KEY    @"B5YC37ztRDo4ZmBsmppelQ" //okankurtulus@yahoo.com
#define MANDRILL_API_KEY    @"Z8ZJYcld1Ppop-OUHgK06g"   //Rob@peppermint.com


#define MND_BASE_URL            @"https://mandrillapp.com/api/1.0"
#define MND_ENDPOINT_INFO       @"/users/info.json"
#define MND_ENDPOINT_SEND_MAIL  @"/messages/send.json"


@interface MandrillService : BaseService
@property(strong, nonatomic) NSString *apiKey;

-(void) getInformation;
-(void) sendMessage:(MandrillMessage*) message;

@end