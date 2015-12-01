//
//  ConnectionModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 31/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "ConnectionModel.h"
#import "CacheModel.h"

@implementation ConnectionModel {
    AFNetworkReachabilityManager *afNetworkReachabilityManager;
}

+ (instancetype) sharedInstance {
    return SHARED_INSTANCE( [[self alloc] initShared] );
}

-(id) init {
    NSAssert(false, @"This model instance is singleton so should not be inited - %@", self);
    return nil;
}

-(id) initShared {
    self = [super init];
    if(self) {
        afNetworkReachabilityManager = [AFNetworkReachabilityManager managerForDomain:DOMAIN_PEPPERMINT];
        [self trackConnectionChangeBlock];
        [self beginTracking];
    }
    return self;
}

-(void) dealloc {
    [self stopTracking];
}

#pragma mark - Network

-(BOOL) isInternetReachable
{
    [self beginTracking];
    return afNetworkReachabilityManager.reachable;
}

-(void) beginTracking {
    [afNetworkReachabilityManager startMonitoring];
}

-(void) stopTracking {
    [afNetworkReachabilityManager stopMonitoring];
}

#pragma mark - Network status change

-(void) trackConnectionChangeBlock {
    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //available
                [[CacheModel sharedInstance] triggerCachedMessages];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                //not available
                break;
            default:
                break;
        }
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
}

@end