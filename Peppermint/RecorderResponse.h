//
//  RecorderResponse.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"
#import "Recorder.h"

@interface RecorderResponse : JSONModel
@property (strong, nonatomic) NSString *at;
@property (strong, nonatomic) Recorder *recorder;

@end
