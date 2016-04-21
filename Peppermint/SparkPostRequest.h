//
//  SparkPostRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "SparkPostRecipient.h"
#import "SparkPostContent.h"
#import "SparkPostSubstitutionData.h"
#import "SparkPostOption.h"

@interface SparkPostRequest : JSONModel

@property (strong, nonatomic) NSString *campaign_id;
@property (strong, nonatomic) NSMutableArray<SparkPostRecipient*> *recipients;
@property (strong, nonatomic) SparkPostContent *content;
@property (strong, nonatomic) SparkPostSubstitutionData *substitution_data;
@property (strong, nonatomic) SparkPostOption *options;

@end