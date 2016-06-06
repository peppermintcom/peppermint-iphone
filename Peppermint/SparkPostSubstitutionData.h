//
//  SparkPostSubstitutionData.h
//  Peppermint
//
//  Created by Okan Kurtulus on 18/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface SparkPostSubstitutionData : JSONModel
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *from_name;
@property (strong, nonatomic) NSString *canonical_url;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *replyLink;
@property (strong, nonatomic) NSString *reply_to;
@property (strong, nonatomic) NSString *transcription;
@end
