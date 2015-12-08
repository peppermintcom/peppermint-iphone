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
#import "SpotlightModel.h"
#import "FastReplyModel.h"
#import "ConnectionModel.h"
#import "CacheModel.h"

@import CoreSpotlight;
@import MobileCoreServices;

@interface AppDelegate ()

@end

@implementation AppDelegate {
    __block UIBackgroundTaskIdentifier bgTask;
}

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

-(void) initConnectionStatusChangeListening {
    [ConnectionModel sharedInstance];
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
    [self initConnectionStatusChangeListening];
    REGISTER();
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    PUBLISH([ApplicationWillResignActive new]);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(self.mutableArray.count > 0) {
        bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [[CacheModel sharedInstance] cacheOngoingMessages];
            [application endBackgroundTask:bgTask];
             bgTask = UIBackgroundTaskInvalid;
        }];
    }
}

SUBSCRIBE(DetachSuccess) {
    if(self.mutableArray.count == 0 ) {
        NSLog(@"All send message processes are completed!!!!Secure to exit the app...");
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    } else {
        NSLog(@"A sendvoicemessageModel is detached but there are still %d items in the queue", (int)self.mutableArray.count);
    }
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
    [[CacheModel sharedInstance] cacheOngoingMessages];
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
    if ([NSUserActivityTypeBrowsingWeb isEqualToString: userActivity.activityType]) {
        if(![self handleOpenURL:userActivity.webpageURL sourceApplication:nil annotation:nil]) {
           return [application openURL:userActivity.webpageURL];
        }
        return YES;
    } else if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        NSString *uniqueIdentifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        // Handle 'uniqueIdentifier'
        NSLog(@"searh item uniqueIdentifier: %@", uniqueIdentifier);
        return [SpotlightModel handleSearchItemUniqueIdentifier:uniqueIdentifier];
    }
    return NO;
}

-(BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = NO;
    
    NSDictionary *customAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      url, @"url",
                                      sourceApplication, @"sourceApplication",
                                      nil];
    [Answers logCustomEventWithName:@"HandleUrl" customAttributes:customAttributes];
    
    if([[[url host] lowercaseString] isEqualToString:HOST_FASTREPLY]
       || [[[url path] lowercaseString] containsString:HOST_FASTREPLY]) {
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
            result = [[FastReplyModel sharedInstance] setFastReplyContactWithNameSurname:nameSurname email:email];
        } else {
            NSLog(@"Query Parameters are not valid!");
        }
    } else if ([[[url path] lowercaseString] containsString:PATH_VERIFIY_EMAIL]) {
        
#warning "Verify email locally with parsing the url parameters from base64 encoded json data"        
        result = YES;
        UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:rootVC.view animated:YES];
        });
        dispatch_async(LOW_PRIORITY_QUEUE, ^{
            [NSData dataWithContentsOfURL:url]; //Verify email on the server
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:rootVC.view animated:YES];
            });
        });
    } else if ([[[url path] lowercaseString] containsString:PATH_RESET]) {
        NSLog(PATH_RESET);
    } else if ([[[url path] lowercaseString] containsString:PATH_SIGNIN]) {
        NSLog(PATH_SIGNIN);
    } else {
        NSLog(@"handleOpenURL failed for URL: %@", url.host);
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

#pragma mark - Handle Error

+(void) logErrorToAnswers:(NSError*) error {
    NSMutableDictionary *logDictionary = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    [logDictionary setValue:[NSNumber numberWithInt:error.code] forKey:@"Code"];
    [logDictionary setValue:error.domain forKey:@"Domain"];
    [logDictionary setValue:error.localizedDescription forKey:@"LocalizedDescription"];
    [logDictionary setValue:error.description forKey:@"Description"];
    [Answers logCustomEventWithName:@"NSError handled with alert" customAttributes:logDictionary];
}

+(NSString*) messageForError:(NSError*) error {
    NSString *message = error.localizedDescription;
    if([error.domain isEqualToString:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorNotConnectedToInternet:
            case NSURLErrorNetworkConnectionLost:
                message = LOC(@"Please check your internet connection and try again", @"message");
#warning "Handle the below message. Maybe in view controller"
                //message = LOC(@"Please connect to the internet to upload the message", @"message");
                break;
            default:
                message = LOC(@"Connection error", @"message");
                break;
        }
    } else if ([error.domain isEqualToString:@"com.google.GIDSignIn"]) {
        switch (error.code) {
            default:
                message = LOC(@"Please connect to the Internet then Log In", @"message");
                break;
        }
    } else if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
        switch (error.code) {
            default:
                message = LOC(@"Please check your login information", @"message");
                break;
        }
    } else if ([error.domain isEqualToString:NSOSStatusErrorDomain]) {
        switch (error.code) {
            case AVAudioSessionErrorInsufficientPriority:
                message = LOC(@"Microphone is in use", @"message");
                break;
            default:
                break;
        }
    }
    return message;
}

+(void) handleError:(NSError*) error {
    [self logErrorToAnswers:error];
    NSString *title = LOC(@"An error occured", @"Error Title Message");
    NSString *message = [self messageForError:error];
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

#pragma mark - Loggin message procesdure

SUBSCRIBE(RetrieveSignedUrlSuccessful) {
    NSLog(@"RetrieveSignedUrlSuccessful %@\nSignedUrl:%@", event.short_url, event.signedUrl);
}

SUBSCRIBE(FileUploadCompleted) {
    NSLog(@"FileUploadCompleted %@", event.signedUrl);
}

@end
