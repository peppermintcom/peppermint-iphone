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
    AFNetworkReachabilityStatus previousReachabilityStatus;
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
        previousReachabilityStatus = AFNetworkReachabilityStatusUnknown;
        [self trackConnectionChangeBlock];
        [self beginTracking];
    }
    return self;
}

-(void) dealloc {
    [self stopTracking];
}

#pragma mark - Network

-(BOOL) isInternetReachable {
    BOOL isConnected = afNetworkReachabilityManager.reachable;
    if (!isConnected) {
        NSError *error;
        NSString *urlString = [NSString stringWithFormat:@"https://%@", DOMAIN_PEPPERMINT];
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        isConnected = (!error && data.length > 0);
    }
    return isConnected;
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
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                if(previousReachabilityStatus == AFNetworkReachabilityStatusUnknown
                   || previousReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
                    //Only trigger when passing from unknown or not connected
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CACHE_TRIGGER_DELAY_ON_CONNECTION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[CacheModel sharedInstance] triggerCachedMessages];
                    });
                }
                break;
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusNotReachable:
                break;
            default:
                break;
        }
        previousReachabilityStatus = status;
    }];
}

@end