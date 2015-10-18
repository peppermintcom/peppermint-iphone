//
//  MandrillToObject.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

#define TYPE_TO     @"to"
#define TYPE_CC     @"cc"
#define TYPE_BCC    @"bcc"

@protocol MandrillToObject
@end

@interface MandrillToObject : JSONModel
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;
@end
