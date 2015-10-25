//
//  RecorderRequest.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSonModel.h"
#import "Recorder.h"

@interface RecorderRequest : JSONModel
@property (strong, nonatomic) NSString *api_key;
@property (strong, nonatomic) Recorder *recorder;

@end
