//
//  CacheModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 07/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@interface CacheModel : BaseModel

+ (instancetype) sharedInstance;
-(void) cache:(BaseModel*) model WithData:(NSData*) data extension:(NSString*) extension;
-(void) triggerCachedMessages;

@end
