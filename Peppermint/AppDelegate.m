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
#import "LoginNavigationViewController.h"
#import "ContactsViewController.h"
#import "LoginValidateEmailViewController.h"
#import "LoginViewController.h"
#import "JwtInformation.h"
#import "Flurry.h"
#import "GAI.h"
#import "AnalyticsModel.h"
#import "GAIFields.h"
#import "GoogleCloudMessagingModel.h"
#import "AWSModel.h"
#import "ChatEntriesViewController.h"
#import "AutoPlayModel.h"
#import "AudioSessionModel.h"

@import WatchConnectivity;
@import Contacts;
@import CoreSpotlight;
@import MobileCoreServices;

#define PATH_EMAIL          @"gcm.notification.sender_email"
#define PATH_FULL_NAME      @"gcm.notification.sender_name"

@interface AppDelegate () <WCSessionDelegate, GGLInstanceIDDelegate, ChatEntryModelDelegate>
@end

@implementation AppDelegate {
    __block UIBackgroundTaskIdentifier bgTaskForMessageSending;
    __block UIBackgroundTaskIdentifier bgTaskForSync;
    AWSModel *awsModel;
    UIView *appLoadingView;
    PeppermintContact *peppermintContactToNavigate;
    PlayingModel *playingModel;
    ChatEntryModel *chatEntryModel;
    void (^cachedCompletionHandler)(UIBackgroundFetchResult);
    NSDate *fetchStart;
    BOOL hasFinishedFirstSync;
}

-(void) initPlayingModel {
    playingModel = [PlayingModel new];
    [playingModel initReceivedMessageSound];
}

-(void) initMutableArray {
    if(!self.mutableArray) {
        self.mutableArray = [NSMutableArray new];
    }
}

-(void) initNavigationViewController {
    [[UINavigationBar appearance] setBarTintColor:[UIColor peppermintGreen]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    appLoadingView = nil;
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
    
    
    if(![[nvc.viewControllers firstObject] isKindOfClass:[ReSideMenuContainerViewController class]]) {
        BOOL isTutorialShowed = [defaults_object(DEFAULTS_KEY_ISTUTORIALSHOWED) boolValue];
        if(isTutorialShowed) {
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_MAIN];
            [nvc pushViewController:vc animated:NO];
        }
    }
    
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
    self.window.frame = [[UIScreen mainScreen] bounds];
}

-(void) initFabric {
#ifdef DEBUG
    [Fabric with:@[[Crashlytics class]]];
#else
    [Fabric with:@[[Crashlytics class]]];
#endif
}

-(void) initFlurry {
    [Flurry startSession:FLURRY_API_KEY];
}

-(void) initGoogleAnalytics {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
#ifdef DEBUG
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelNone];
#else
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelNone];
#endif
    [GAI sharedInstance].dispatchInterval = 20;    
    NSString *trackingId = [[[GGLContext sharedInstance] configuration] trackingID];
    [[GAI sharedInstance] trackerWithTrackingId:trackingId];
    
/*
    id<GAITracker> tracker =
    NSString *userId = [PeppermintMessageSender sharedInstance].email;
    userId = userId == nil ? @"unauthorizedUser" : userId;
    [tracker set:kGAIUserId value:userId];
*/
}

-(void) initWatchKitSession {
  if (NSClassFromString(@"WCSession")) {
    if ([WCSession isSupported]) {
      [WCSession defaultSession].delegate = self;
      [[WCSession defaultSession] activateSession];
    }
  }
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

-(void) initConnectionStatusChangeListening {
    [ConnectionModel sharedInstance];
}

-(void) checkForFirstRun {
    BOOL isFirstRun = ![[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_KEY_IS_FIRST_RUN];
    if(isFirstRun) {
        [[PeppermintMessageSender sharedInstance] clearSender];
        defaults_set_object(DEFAULTS_KEY_IS_FIRST_RUN, DEFAULTS_KEY_IS_FIRST_RUN);
        [self initLocalNotification];
    }
}

-(void) initLocalNotification {
    UIApplication *application = [UIApplication sharedApplication];
    [application cancelAllLocalNotifications];
    
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:3 * MINUTE];
    notif.timeZone = [NSTimeZone defaultTimeZone];
    
    notif.alertBody = LOC(@"You have installed Peppermint. Click to send your first message!", @"Notification Message");
    notif.alertAction = @"Send now!";
    notif.soundName = @"alert.caf";
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

-(void) initRecorder {
    if(!awsModel) {
        awsModel = [AWSModel new];
    }
    [awsModel initRecorder];
}

-(void) initGCM {
    GoogleCloudMessagingModel *googleCloudMessagingModel = [GoogleCloudMessagingModel sharedInstance];
    [googleCloudMessagingModel initGCM];
}

-(void) initGoogleApp {
    NSError* error;
    // Configure the Google context: parses the GoogleService-Info.plist, and initializes the services that have entries in the file
    [[GGLContext sharedInstance] configureWithError: &error];
    if(error) {
        NSLog(@"Error configuring Google services: %@", error);
    } else {
        [self initGCM];
    }
}

-(void) refreshIncomingMessages {
    if(!chatEntryModel) {
        chatEntryModel = [ChatEntryModel new];
        chatEntryModel.delegate = self;
        hasFinishedFirstSync = NO;
    }
    [chatEntryModel makeSyncRequestForMessages];
}

-(void) setBackgrounFetchInterval {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initPlayingModel];
    [self initMutableArray];
    [self initNavigationViewController];
    [self initFabric];
    [self initFlurry];
    [self initGoogleAnalytics];
    [self initInitialViewController];
    //[self logServiceCalls];
    [self initFacebookAppWithApplication:application launchOptions:launchOptions];
    [self initConnectionStatusChangeListening];
    [self initWatchKitSession];
    [self initGoogleApp];
    [self checkForFirstRun];
    [self initRecorder];
    [self setBackgrounFetchInterval];
    REGISTER();
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //PUBLISH([ApplicationWillEnterForeground new]);
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    hasFinishedFirstSync = NO;
    [FBSDKAppEvents activateApp];
    [[GoogleCloudMessagingModel sharedInstance] connectGCM];
    [self refreshIncomingMessages];
    [self refreshBadgeNumber];
    PUBLISH([ApplicationDidBecomeActive new]);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self refreshBadgeNumber];
    PUBLISH([ApplicationWillResignActive new]);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[GoogleCloudMessagingModel sharedInstance] disconnectGCM];
    if(self.mutableArray.count > 0) {
        bgTaskForMessageSending = [application beginBackgroundTaskWithExpirationHandler:^{
            [[CacheModel sharedInstance] cacheOngoingMessages];
            [application endBackgroundTask:bgTaskForMessageSending];
             bgTaskForMessageSending = UIBackgroundTaskInvalid;
        }];
    }
    if([chatEntryModel isSyncProcessActive]) {
        bgTaskForSync = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:bgTaskForSync];
            bgTaskForSync = UIBackgroundTaskInvalid;
        }];
    }
}

SUBSCRIBE(DetachSuccess) {
    if(self.mutableArray.count == 0 ) {
        NSLog(@"All send message processes are completed!!!!Secure to exit the app...");
        [[UIApplication sharedApplication] endBackgroundTask:bgTaskForMessageSending];
        bgTaskForMessageSending = UIBackgroundTaskInvalid;
    } else {
        NSLog(@"A sendvoicemessageModel is detached but there are still %d items in the queue", (int)self.mutableArray.count);
    }
}

-(void) finishSyncBackgroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:bgTaskForSync];
    bgTaskForSync = UIBackgroundTaskInvalid;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.    
    [[AudioSessionModel sharedInstance] updateSessionState:NO];
    [[CacheModel sharedInstance] cacheOngoingMessages];
    [self saveContext];
}

#pragma mark - Notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    GoogleCloudMessagingModel *googleCloudMessagingModel = [GoogleCloudMessagingModel sharedInstance];
    BOOL isDebug = NO;
#ifdef DEBUG
    isDebug = YES;
#endif
    googleCloudMessagingModel.registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                                                      kGGLInstanceIDAPNSServerTypeSandboxOption:[NSNumber numberWithBool:isDebug]};
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:googleCloudMessagingModel.gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:googleCloudMessagingModel.registrationOptions
                                                      handler:googleCloudMessagingModel.registrationHandler];
}

- (void)onTokenRefresh {
    // A rotation of the registration tokens is happening, so the app needs to request a new token.
    NSLog(@"The GCM registration token needs to be changed.");
    GoogleCloudMessagingModel *googleCloudMessagingModel = [GoogleCloudMessagingModel sharedInstance];
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:googleCloudMessagingModel.gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:googleCloudMessagingModel.registrationOptions
                                                      handler:googleCloudMessagingModel.registrationHandler];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handleNotification:userInfo inApplication:application];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    [self handleNotification:userInfo inApplication:application];
    handler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    NSLog(@"handleActionWithIdentifier:completionHandler: is called with action %@", identifier);
    if([identifier isEqualToString:CATEGORY_IDENTIFIER_REPLY]) {
        NSString *userEmail = [userInfo valueForKey:PATH_EMAIL];
        NSString *userNameSurname = [userInfo valueForKey:PATH_FULL_NAME];
        if(userEmail && userNameSurname) {
            [[FastReplyModel sharedInstance] setFastReplyContactWithNameSurname:userNameSurname email:userEmail];
        }
        weakself_create();
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf navigateToChatEntriesPageForEmail:userEmail nameSurname:userNameSurname];
        });
    }
    completionHandler();
}

- (void) handleNotification:(NSDictionary*)userInfo inApplication:(UIApplication *)application {
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
    [self refreshIncomingMessages];
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"Got notification when the app is active. Data payload will be handled, so not doing any handling.");
    } else if(application.applicationState == UIApplicationStateInactive) {
        [self gotGCMNotificationForAutoPlay:userInfo];
    } else if (application.applicationState == UIApplicationStateBackground) {
        NSLog(@"Got notification when the app is in background. Data payload will be handled, so not doing any handling.");
    }
}

#pragma mark - Backgroun Fetch

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    fetchStart = [NSDate new];
    cachedCompletionHandler = completionHandler;
    [self refreshIncomingMessages];
}

#pragma mark - AutoPlay

-(void) gotGCMNotificationForAutoPlay:(NSDictionary*)userInfo {
    BOOL isUserStillLoggedIn = [[PeppermintMessageSender sharedInstance] isUserStillLoggedIn];
    if(isUserStillLoggedIn) {
        [self showAppCoverLoading];
        peppermintContactToNavigate = [PeppermintContact new];
        peppermintContactToNavigate.nameSurname = [userInfo valueForKey:PATH_FULL_NAME];
        peppermintContactToNavigate.communicationChannelAddress = [userInfo valueForKey:PATH_EMAIL];
        [[AutoPlayModel sharedInstance] scheduleAutoPlayForPeppermintContact:peppermintContactToNavigate];
    }
}

#pragma mark - ChatEntryModelDelegate
-(void) peppermintChatEntriesArrayIsUpdated {
    NSLog(@"peppermintChatEntriesArrayIsUpdated");
}

-(NSArray*) filterNewIncomingMessagesInArray:(NSArray*)peppermintChatEntryArray {
    NSMutableArray *newMessagesArray = [NSMutableArray new];
    for(PeppermintChatEntry *peppermintChatEntry in peppermintChatEntryArray) {
        if(peppermintChatEntry.performedOperation == PerformedOperationCreated
           && peppermintChatEntry.isSeen == NO ) {
            [newMessagesArray addObject:peppermintChatEntry];
        }
    }
    return newMessagesArray;
}

-(void) peppermintChatEntrySavedWithSuccess:(NSArray<PeppermintChatEntry*>*) savedPeppermintChatEnryArray {
    [self finishSyncBackgroundTask];
    [self hideAppCoverLoadingView];
    NSArray<PeppermintChatEntry*> *newMessagesArray = [self filterNewIncomingMessagesInArray:savedPeppermintChatEnryArray];
    [self refreshBadgeNumber];
    
    if(peppermintContactToNavigate
       && peppermintContactToNavigate.nameSurname.length > 0
       && peppermintContactToNavigate.communicationChannelAddress.length > 0) {
        [self navigateToChatEntriesPageForEmail:peppermintContactToNavigate.communicationChannelAddress
                                    nameSurname:peppermintContactToNavigate.nameSurname];
        peppermintContactToNavigate = nil;
    } else if (newMessagesArray.count > 0 && !newMessagesArray.firstObject.isSentByMe && hasFinishedFirstSync) {
        [playingModel playPreparedAudiowithCompetitionBlock:nil];
    }
    
    hasFinishedFirstSync = YES;
    
    RefreshIncomingMessagesCompletedWithSuccess *refreshIncomingMessagesCompletedWithSuccess = [RefreshIncomingMessagesCompletedWithSuccess new];
    refreshIncomingMessagesCompletedWithSuccess.sender = self;
    refreshIncomingMessagesCompletedWithSuccess.peppermintChatEntryNewMesssagesArray = newMessagesArray;
    refreshIncomingMessagesCompletedWithSuccess.peppermintChatEntryAllMesssagesArray = savedPeppermintChatEnryArray;
    PUBLISH(refreshIncomingMessagesCompletedWithSuccess);
    
    if(cachedCompletionHandler) {
        NSDate *fetchEnd = [NSDate date];
        NSTimeInterval timeElapsed = [fetchEnd timeIntervalSinceDate:fetchStart];
        NSLog(@"Background Fetch Duration: %f seconds", timeElapsed);
        if(newMessagesArray.count > 0) {
            cachedCompletionHandler(UIBackgroundFetchResultNewData);
            NSLog(@"UIBackgroundFetchResultNewData");
        } else {
            cachedCompletionHandler(UIBackgroundFetchResultNoData);
            NSLog(@"UIBackgroundFetchResultNoData");
        }
    }
}

-(void) operationFailure:(NSError *)error {
    if(cachedCompletionHandler) {
        cachedCompletionHandler(UIBackgroundFetchResultFailed);
    }
    
#ifdef DEBUG
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    [dict setObject:@"This happened in debug mode" forKey:@"error log time"];
    error = [NSError errorWithDomain:error.domain code:error.code userInfo:dict];
    [AnalyticsModel logError:error];
#endif
}

#pragma mark - Navigation

-(void) navigateToChatEntriesPageForEmail:(NSString*)email nameSurname:(NSString*) nameSurname {
    UIViewController *vc = [self visibleViewController];
    if([vc isKindOfClass:[ReSideMenuContainerViewController class]]) {
        ReSideMenuContainerViewController *reSideMenuContainerViewController = (ReSideMenuContainerViewController*)vc;
        UINavigationController *nvc = (UINavigationController*) reSideMenuContainerViewController.contentViewController;
        
        UIViewController *vc = nvc.viewControllers.lastObject;
        BOOL isInCorrectScreen = [vc isKindOfClass:[ChatEntriesViewController class]]
        && [((ChatEntriesViewController*)vc).peppermintContact.communicationChannelAddress isEqualToString:email];
        
        if(isInCorrectScreen) {
            ChatEntriesViewController *chatEntriesViewController = (ChatEntriesViewController*)vc;
            [chatEntriesViewController refreshContent];
        } else {
            [nvc popToRootViewControllerAnimated:NO];
            ContactsViewController *contactsViewController = (ContactsViewController*)[nvc.viewControllers objectAtIndex:0];
            if(contactsViewController) {
                [contactsViewController scheduleNavigateToChatEntryWithEmail:email];
            }
        }
    } else {
        NSLog(@"Can not navigate to ChatEntries");
    }
}

-(BOOL) navigateToContactsWithFilterText:(NSString*) nameSurname {
    BOOL result = NO;
    UIViewController *vc = [self visibleViewController];
    if([vc isKindOfClass:[ReSideMenuContainerViewController class]]) {
        ReSideMenuContainerViewController *reSideMenuContainerViewController = (ReSideMenuContainerViewController*)vc;
        UINavigationController *nvc = (UINavigationController*) reSideMenuContainerViewController.contentViewController;
        [nvc popToRootViewControllerAnimated:YES];
        ContactsViewController *contactsViewController =(ContactsViewController*)[nvc.viewControllers firstObject];
        contactsViewController.searchContactsTextField.text = contactsViewController.contactsModel.filterText = nameSurname;
        [contactsViewController refreshContacts];
        result = YES;
    } else {
        NSLog(@"Can not navigate to ContactsViewController");
    }
    return result;
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
    NSString *host = [[url host] lowercaseString];
    NSString *path = [[url path] lowercaseString];
    
    
    if([host isEqualToString:HOST_FASTREPLY]
       || [path containsString:HOST_FASTREPLY]) {
        result = YES;
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSString *nameSurname, *email = nil;
        for(NSURLQueryItem *queryItem in urlComponents.queryItems) {
            if([queryItem.name isEqualToString:QUERY_COMPONENT_NAMESURNAME]) {
                nameSurname = queryItem.value;
            } else if ([queryItem.name isEqual:QUERY_COMPONENT_EMAIL]) {
                email = queryItem.value;
            }
        }
        
        if(nameSurname.length > 0 && [email isValidEmail]) {
            result = [[FastReplyModel sharedInstance] setFastReplyContactWithNameSurname:nameSurname email:email];
            if(result) {
                [self navigateToChatEntriesPageForEmail:email nameSurname:nameSurname];
            }
        }
        else {
            NSLog(@"Query Parameters are not valid!");
        }
        
    } else if ([path containsString:PATH_VERIFIY_EMAIL]
               || [path containsString:PATH_VERIFIED]
               || [host containsString:PATH_VERIFIY_EMAIL]
               || [host containsString:PATH_VERIFIED]) {
        result = [self validateEmailWithUrl:url];
    } else if ([path containsString:PATH_BACK_TO_APP] || [host containsString:PATH_BACK_TO_APP]) {
        NSLog(PATH_BACK_TO_APP);
        result = YES;
    } else if ([path containsString:PATH_RESET] || [host containsString:PATH_RESET]) {
        NSLog(PATH_RESET);
        result = YES;
    } else if ([path containsString:PATH_SIGNIN]
               || [host containsString:PATH_SIGNIN]) {
        NSLog(PATH_SIGNIN);
        UINavigationController *nvc = [self visibleViewController].navigationController;
        if(![nvc isKindOfClass:[LoginNavigationViewController class]]) {
            [LoginNavigationViewController logUserInWithDelegate:nil completion:nil];
        }
        result = YES;
    } else {
        NSString *errorText = [NSString stringWithFormat:@"handleOpenURL failed for URL: %@", url.host];
        [AnalyticsModel logError:[NSError errorWithDomain:errorText code:-1 userInfo:[NSDictionary new]]];
        NSLog(@"%@",errorText);
    }
    return result;
}

-(BOOL) validateEmailWithUrl:(NSURL*) url {
    JwtInformation *jwtInformation = [JwtInformation instancewithJwt:url.query andError:nil];
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    
    BOOL result = jwtInformation != nil && [peppermintMessageSender.email isEqualToString:jwtInformation.sub];
    if(result) {
        [self showAppCoverLoading];
        weakself_create();
        dispatch_async(LOW_PRIORITY_QUEUE, ^{
            [NSData dataWithContentsOfURL:url]; //--> Verify email on the server
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf navigateToVerifyEmail];
                [weakSelf hideAppCoverLoadingView];
            });
        });
    }
    return result;
}

-(void) navigateToVerifyEmail {
    UIViewController *vc = self.visibleViewController;
    if([vc isKindOfClass:[LoginValidateEmailViewController class]]) {
        LoginValidateEmailViewController *loginValidateEmailViewController = (LoginValidateEmailViewController*)vc;
        [loginValidateEmailViewController checkIfAccountIsVerified];
    } else if ([vc isKindOfClass:[LoginViewController class]]) {
        LoginNavigationViewController *loginNavigationViewController = (LoginNavigationViewController*)vc.navigationController;
        [loginNavigationViewController loginSucceed];
    } else {
        NSLog(@"Could not navigate to verify email."); //This case is not possible with current ViewController hierarchy, this warning will be useful if view hierarchy is updated and functionality will not work as expected
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
    @synchronized(self) {
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
    }
    return _persistentStoreCoordinator;
}

-(void) cleanDatabase {
    NSLog(@"\n\n\n");
    NSLog(@"*******************************************");
    NSLog(@"****CLEANING ALL RECORDS IN DATABASE*******");
    NSLog(@"*******************************************\n\n\n");
    
    NSPersistentStoreCoordinator *nsPersistentStoreCoordinator = [self persistentStoreCoordinator];
    NSArray *stores = [nsPersistentStoreCoordinator persistentStores];
    for(NSPersistentStore *store in stores) {
        [nsPersistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    _persistentStoreCoordinator = nil;
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

+(NSString*) messageForError:(NSError*) error {
    NSString *message = error.localizedDescription;
    if([error.domain isEqualToString:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorNotConnectedToInternet:
            case NSURLErrorNetworkConnectionLost:
            default:
                message = LOC(@"Please check your internet connection and try again", @"message");
                break;
        }
    } else if ([error.domain isEqualToString:@"com.google.GIDSignIn"]) {
        switch (error.code) {
            case -2:
                message = error.localizedDescription;
                break;
            default:
                message = LOC(@"Please connect to the Internet then Log In", @"message");
                break;
        }
    } else if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
        switch (error.code) {
            case CODE_WRONG_CREDENTIALS:
                message = LOC(@"Please check your login information", @"message");
                break;
            default:
                message = LOC(@"Please try again later", @"message");
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
    } else if ([error.domain isEqualToString:@"Could not start recording"]) {
        message = LOC(@"Microphone is in use", @"message");
    } else if ([error.domain isEqualToString:DOMAIN_MANDRILL]) {
        message = LOC(@"Mandrill message can not be delivered", @"Mandrill message can not be delivered");
    }
    return message;
}

+(void) handleError:(NSError*) error {
    NSLog(@"An error occured:\n%@", error);
    [AnalyticsModel logError:error];
    NSString *title = LOC(@"An error occured", @"Error Title Message");
    NSString *message = [self messageForError:error];
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

#pragma mark - VisibleViewController

- (UIViewController *)visibleViewController {
    UIViewController *rootViewController = self.window.rootViewController;
    return [self getVisibleViewControllerFrom:rootViewController];
}

- (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

#pragma mark - Inter App Messaging

SUBSCRIBE(NewUserLoggedIn) {
    chatEntryModel = nil;
    [self initRecorder];
    [self navigateToContactsWithFilterText:@""];
}

SUBSCRIBE(AccountIdIsUpdated) {
    [self refreshIncomingMessages];
}

-(void) tryToSetUpAccountWithRecorder {
    [awsModel tryToSetUpAccountWithRecorder];
}

-(void) tryToUpdateGCMRegistrationToken  {
    [awsModel tryToUpdateGCMRegistrationToken];
}

-(void) refreshBadgeNumber {
    NSUInteger unreadMessagesCount = [chatEntryModel unreadMessageCountOfAllChats];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadMessagesCount];
}

#pragma mark - App Cover Loading

-(void) showAppCoverLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(appLoadingView) {
            [appLoadingView removeFromSuperview];
        }
        appLoadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        appLoadingView.backgroundColor = [UIColor clearColor];
        [[[UIApplication sharedApplication] keyWindow] addSubview:appLoadingView];
        [MBProgressHUD showHUDAddedTo:appLoadingView animated:YES];
    });
}

-(void) hideAppCoverLoadingView {
    if(appLoadingView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:appLoadingView animated:YES];
            [appLoadingView removeFromSuperview];
        });
    }
}

@end
