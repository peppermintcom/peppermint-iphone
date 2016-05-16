//
//  AnalyticsModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 16/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface AnalyticsModel : BaseModel
+(void) logError:(NSError*) error;
+(NSError*) addCustomInfo:(NSString*)information toError:(NSError*)error;

@end
