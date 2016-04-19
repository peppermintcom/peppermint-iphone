//
//  SparkPostFrom.h
//  Peppermint
//
//  Created by Okan Kurtulus on 19/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface SparkPostFrom : JSONModel
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *name;
@end
