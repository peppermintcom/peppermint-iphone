//
//  FinalizeUploadResponse.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface FinalizeUploadResponse : JSONModel
@property (strong, nonatomic) NSString *canonical_url;
@property (strong, nonatomic) NSString *short_url;
@end
