//
//  JwtsResponse.h
//  Peppermint
//
//  Created by Okan Kurtulus on 02/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "Data.h"

@interface JwtsResponse : JSONModel
@property (strong, nonatomic) Data* data;
@end
