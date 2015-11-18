//
//  AppDelegate.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "AFNetworkActivityLogger.h"
#import "Tolo.h"
#import "Events.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/SignIn.h>
#import "RecordingViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void) initMutableArray {
    if(!self.mutableArray) {
        self.mutableArray = [NSMutableArray new];
    }
}

-(void) initNavigationViewController {
    [[UINavigationBar appearance] setBarTintColor:[UIColor peppermintGreen]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void) initInitialViewController {
    NSString *mainStoryBoardName = [UIStoryboard LDMainStoryboardName];
    if([mainStoryBoardName isEqualToString:STORYBOARD_MAIN]) {
        [self initMainStoryBoardForTutorial];
    }
}

-(void) initMainStoryBoardForTutorial {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:nil];
    UINavigationController *nvc = [storyboard instantiateInitialViewController];
    
    BOOL isTutorialShowed = [defaults_object(DEFAULTS_KEY_ISTUTORIALSHOWED) boolValue];
    if(isTutorialShowed) {
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_MAIN];
        [nvc pushViewController:vc animated:NO];
    }
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
    self.window.frame = [[UIScreen mainScreen] bounds];
}

-(void) initFabric {
#ifdef DEBUG
#else
    [Fabric with:@[[Crashlytics class]]];
#endif
}

-(void) logServiceCalls {
#ifdef DEBUG
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
#endif
}

-(void) initFacebookAppWithApplication:(UIApplication*) application launchOptions:(NSDictionary*)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
}

-(void) initGoogleApp {
    NSError* error;
    [[GGLContext sharedInstance] configureWithError: &error];
    NSLog(@"Error configuring Google services: %@", error);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initMutableArray];
    [self initNavigationViewController];
    [self initFabric];
    [self initInitialViewController];
    [self logServiceCalls];
    [self initFacebookAppWithApplication:application launchOptions:launchOptions];
    [self initGoogleApp];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    PUBLISH([ApplicationWillResignActive new]);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //PUBLISH([ApplicationDidEnterBackground new]);
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //PUBLISH([ApplicationWillEnterForeground new]);
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    PUBLISH([ApplicationDidBecomeActive new]);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

#pragma mark - Open URL

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = NO;
    if([url.scheme isEqualToString:SCHEME_FACEBOOK]) {
        result = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                openURL:url
                                                      sourceApplication:sourceApplication
                                                             annotation:annotation];
    } else if ([url.scheme isEqualToString:SCHEME_GOOGLE]) {
        result = [[GIDSignIn sharedInstance] handleURL:url
                            sourceApplication:sourceApplication
                                   annotation:annotation];
    } else if ([url.scheme isEqualToString:SCHEME_PEPPERMINT]) {
        return [self handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation];
    }
    return result;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
#warning "Add url redirect for possible unhandled url"
    if ([NSUserActivityTypeBrowsingWeb isEqualToString: userActivity.activityType]) {
        if(![self handleOpenURL:userActivity.webpageURL sourceApplication:nil annotation:nil]) {
            [[UIApplication sharedApplication] openURL:userActivity.webpageURL];
        }
    }
    return YES;
}

-(BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = NO;
    if([[url host] isEqualToString:HOST_FASTREPLY]
       || [[[url path] lowercaseString] containsString:PATH_FASTREPLY]) {
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSString *nameSurname, *email = nil;
        for(NSURLQueryItem *queryItem in urlComponents.queryItems) {
            if([queryItem.name isEqualToString:QUERY_COMPONENT_NAMESURNAME]) {
                nameSurname = queryItem.value;
            } else if ([queryItem.name isEqual:QUERY_COMPONENT_EMAIL]) {
                email = queryItem.value;
            }
        }
        if(nameSurname && email) {
            result = [RecordingViewController sendFastReplyToUserWithNameSurname:nameSurname withEmail:email];
        } else {
            NSLog(@"Query Parameters are not valid!");
        }
    } else if ([[[url path] lowercaseString] containsString:PATH_VERIFIY_EMAIL]) {
        result = YES;
        UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
        [MBProgressHUD showHUDAddedTo:rootVC.view animated:YES];
        dispatch_async(LOW_PRIORITY_QUEUE, ^{
            [NSData dataWithContentsOfURL:url]; //Verify email on the server
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:rootVC.view animated:YES];
            });
        });
    } else {
        NSLog(@"Host is not avaible to handle. Host : %@", url.host);
    }
    return result;
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
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
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
+ (AppDelegate*) Instance {
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    return (AppDelegate*) appDelegate;
}

@end
