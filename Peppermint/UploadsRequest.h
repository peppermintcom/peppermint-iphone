//
//  UploadsRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface UploadsRequest : JSONModel
@property(strong, nonatomic) NSString *content_type;
@end