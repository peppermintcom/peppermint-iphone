//
//  ExtensionDelegate.m
//  Watch Extension
//
//  Created by Yan Saraev on 11/18/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "A0SimpleKeychain.h"
#import "PeppermintMessageSender.h"

@import WatchConnectivity;

@interface ExtensionDelegate () <WCSessionDelegate>


@end

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    // Perform any final initialization of your application.
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  [WCSession defaultSession].delegate = self;
  [[WCSession defaultSession] activateSession];
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

#pragma mark- Watch Connectivity Delegate

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
  NSString * jsonString = applicationContext[@"user"];
  NSLog(@"%s: %@", __PRETTY_FUNCTION__, jsonString);
  [[A0SimpleKeychain keychain] setString:jsonString forKey:KEYCHAIN_MESSAGE_SENDER];
}

@end
