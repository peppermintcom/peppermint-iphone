//
//  MandrillRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "MandrillMessage.h"

#ifdef DEBUG
//#define MANDRILL_API_KEY    @"B5YC37ztRDo4ZmBsmppelQ"   //okankurtulus@yahoo.com
#define MANDRILL_API_KEY    @"Z8ZJYcld1Ppop-OUHgK06g"   //Rob@peppermint.com
#else
#define MANDRILL_API_KEY    @"Z8ZJYcld1Ppop-OUHgK06g"   //Rob@peppermint.com
#endif


@interface MandrillRequest : JSONModel
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) MandrillMessage *message;
@property (strong, nonatomic) NSString *template_name;
@property (strong, nonatomic) NSArray<MandrillNameContentPair> *template_content;

@end