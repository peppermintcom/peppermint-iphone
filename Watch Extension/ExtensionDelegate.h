//
//  ExtensionDelegate.h
//  watch Extension
//
//  Created by Yan Saraev on 1/14/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
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
