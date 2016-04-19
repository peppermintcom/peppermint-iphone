//
//  SparkPostTemplatesResponse.h
//  Peppermint
//
//  Created by Okan Kurtulus on 19/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "SparkPostTemplateResults.h"

@interface SparkPostTemplatesResponse : JSONModel
@property (strong, nonatomic) SparkPostTemplateResults *results;
@end
