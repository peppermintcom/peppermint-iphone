//
//  SparkPostOption.h
//  Peppermint
//
//  Created by Okan Kurtulus on 21/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "JSONModel.h"

@interface SparkPostOption : JSONModel
@property (nonatomic, assign) BOOL open_tracking;
@property (nonatomic, assign) BOOL click_tracking;
@property (nonatomic, assign) BOOL transactional;
@end
