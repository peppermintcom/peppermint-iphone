//
//  TranscriptionsResponse.h
//  Peppermint
//
//  Created by Okan Kurtulus on 30/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TranscriptionsRequest.h"

@interface TranscriptionsResponse : TranscriptionsRequest
@property (strong, nonatomic) NSString *transcription_url;
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *ip_address;
@property (strong, nonatomic) NSString *recorder_id;

@end