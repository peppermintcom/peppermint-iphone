//
//  AppDelegate.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

@import CoreData;
@import Foundation;
@import UIKit;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSMutableArray *mutableArray;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (AppDelegate*) Instance;
+ (void) handleError:(NSError*) error;
- (UIViewController *)visibleViewController;

-(void) tryToSetUpAccountWithRecorder;
-(void) tryToUpdateGCMRegistrationToken;
-(void) refreshIncomingMessages;

-(void) cleanDatabase;
@end
