//
//  SetUpRecorderRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 02/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "Data.h"

@interface SetUpRecorderRequest : JSONModel
@property (strong, nonatomic) NSArray *data;
@end
