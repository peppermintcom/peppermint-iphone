//
//  ConnectionModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"
#import <AFNetworking.h>

@interface ConnectionModel : BaseModel

-(BOOL) isInternetReachable;
-(void) beginTracking;
-(void) stopTracking;

@end