//
//  MandrillRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "MandrillMessage.h"

@interface MandrillRequest : JSONModel
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) MandrillMessage *message;


@end
