//
//  SparkPostContent.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface SparkPostContent : JSONModel
@property (strong, nonatomic) NSString * template_id;
@property (nonatomic, assign) BOOL use_draft_template;
@end
