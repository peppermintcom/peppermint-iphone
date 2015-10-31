//
//  ConnectionModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "ConnectionModel.h"

@implementation ConnectionModel

#pragma mark - nextwork

-(BOOL) isInternetReachable
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

-(void) beginTracking {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

-(void) stopTracking {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

-(void) dealloc {
    [self stopTracking];
}

@end