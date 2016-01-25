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
#import "RecentContactsModel.h"

@import CoreData;
@import WatchConnectivity;

@interface ExtensionDelegate () <WCSessionDelegate>



@end

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
  // Perform any final initialization of your application.
  self.recentContactsModel = [[RecentContactsModel alloc] init];
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
  
  if (!self.recentContactsModel) {
    self.recentContactsModel = [[RecentContactsModel alloc] init];
  }
  
  if (applicationContext[@"user"]) {
    NSString * jsonString = applicationContext[@"user"];
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, jsonString);
    [[A0SimpleKeychain keychain] setString:jsonString
                                    forKey:KEYCHAIN_MESSAGE_SENDER];
  } else if (applicationContext[@"contact"]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"%s: %@", __PRETTY_FUNCTION__, applicationContext[@"contact"]);
      for (NSData * ppm_data in applicationContext[@"contact"]) {
        [self.recentContactsModel save:[PeppermintContact peppermintContactWithData:ppm_data]];
      }
    });
  } else {
    
  }
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PeppermintDataModel" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  int try = 0;
reset:
  if (_persistentStoreCoordinator != nil)
  {
    return _persistentStoreCoordinator;
  }
  
  // Create the coordinator and store
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Peppermint.sqlite"];
  NSError *error = nil;
  NSString *failureReason = @"There was an error creating or loading the application's saved data.";
  
  // Allow inferred migration from the original version of the application.
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
    // Report any error we got.
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
    dict[NSLocalizedFailureReasonErrorKey] = failureReason;
    dict[NSUnderlyingErrorKey] = error;
    error = [NSError errorWithDomain:@"Peppermint DB Error" code:9999 userInfo:dict];
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    NSLog(@"Veri Tabanı şema uyumsuzluğu yaşandı, eski veritabanı silindi.");
    if(try++ <2) {
      _persistentStoreCoordinator = nil;
      goto reset;
    }
    
#ifdef DEBUG
    abort();
#else
#endif
  }
  
  return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
  // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (!coordinator) {
    return nil;
  }
  _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
  [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    NSError *error = nil;
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef DEBUG
      abort();
#else
#endif
    }
  }
}

#pragma mark - Instance
+ (ExtensionDelegate *) Instance {
  return (ExtensionDelegate*)[WKExtension sharedExtension].delegate;
}


@end
