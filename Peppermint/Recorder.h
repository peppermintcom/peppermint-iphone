//
//  Recorder.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface Recorder : JSONModel
@property (strong, nonatomic) NSString<Optional> *recorder_id;
@property (strong, nonatomic) NSString *recorder_client_id;
@property (strong, nonatomic) NSString<Optional> *recorder_key;
//@property (strong, nonatomic) NSString *recorder_ts;

@end
