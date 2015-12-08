//
//  ExtensionDelegate.h
//  Watch Extension
//
//  Created by Yan Saraev on 11/18/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@import CoreData;
@class RecentContactsModel;

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) RecentContactsModel * recentContactsModel;

+ (ExtensionDelegate *) Instance;

@end
