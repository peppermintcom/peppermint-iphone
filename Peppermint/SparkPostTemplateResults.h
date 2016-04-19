//
//  SparkPostTemplateResults.h
//  Peppermint
//
//  Created by Okan Kurtulus on 19/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "SparkPostContent.h"

@interface SparkPostTemplateResults : JSONModel
@property (strong, nonatomic) SparkPostContent *content;

@end
