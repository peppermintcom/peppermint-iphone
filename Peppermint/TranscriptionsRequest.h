//
//  TranscriptionsRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 21/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface TranscriptionsRequest : JSONModel
@property (strong, nonatomic) NSString *audio_url;
@property (strong, nonatomic) NSString *language;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSNumber *confidence;

@end
