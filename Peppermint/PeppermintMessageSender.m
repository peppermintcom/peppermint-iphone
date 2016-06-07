//
//  PeppermintMessageSender.m
//  Peppermint
//
//  Created by Okan Kurtulus on 20/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "PeppermintMessageSender.h"
#import "A0SimpleKeychain.h"

#if !(TARGET_OS_WATCH)
#import "GoogleContactsModel.h"
#import "AppDelegate.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "PeppermintGIdSignIn.h"
#endif

#define KEY                     @"PeppermintMessageSenderJson"
#define SURNAME_EMPTY           @"   "  //We use spaces, cos surname length must be bigger than 0
#define NIL_TEXT                @""

@import WatchConnectivity;

@implementation PeppermintMessageSender

+ (instancetype) sharedInstance {
    static dispatch_once_t pred;
    static PeppermintMessageSender *_sharedManager = nil;
    
    dispatch_once(&pred, ^{
        _sharedManager = [self savedSender];
    });
    return _sharedManager;
}

+(instancetype) savedSender {
    NSError *error;
    PeppermintMessageSender *sender;
    NSString *jsonString = [[A0SimpleKeychain keychain] stringForKey:KEYCHAIN_MESSAGE_SENDER];
    
    BOOL isJsonStringValid = jsonString.length > 0;
    if(isJsonStringValid) {
        sender = [[PeppermintMessageSender alloc] initWithString:jsonString error:&error];
        if(error) {
            NSLog(@"JSON init Error : %@", error);
            isJsonStringValid = NO;
        }
    }    
    if(!isJsonStringValid) {
        sender = [PeppermintMessageSender new];
        [sender clearSender];
#if !(TARGET_OS_WATCH)
        [sender guessNameFromDeviceName];
#endif
    }
    NSAssert(sender != nil, @"sender must not be nil. Please be sure that it is inited!");
    return sender;
}

-(id) init {
    self = [super init];
    if(self) {
#if !(TARGET_OS_WATCH)
        self.imageData = [NSData dataWithContentsOfURL:[self imageFileUrl]];
#endif
    }
    return self;
}

-(void) save {
    NSString *jsonString = [self toJSONString];
    [[A0SimpleKeychain keychain] setString:jsonString forKey:KEYCHAIN_MESSAGE_SENDER];
    
#if !(TARGET_OS_WATCH)
    [self watchSynchronize];
    [self.imageData writeToURL:[self imageFileUrl] atomically:YES];
    
#warning "Consider removing gcmToken check from below logic. Why are we waiting for the GCM token to be ready for registering recorder???"
#if TARGET_OS_SIMULATOR
    if(!self.isAccountSetUpWithRecorder) {
        [[AppDelegate Instance] tryToSetUpAccountWithRecorder];
    }
#else
    if(!self.isAccountSetUpWithRecorder && self.gcmToken.length > 0) {
        [[AppDelegate Instance] tryToSetUpAccountWithRecorder];
    }
#endif
    
    
#endif

}

- (void)watchSynchronize {
  if (NSClassFromString(@"WCSession")) {
    if ([WCSession isSupported]) {
      NSError * err;
      [[WCSession defaultSession] updateApplicationContext:@{@"user":[self toJSONString]} error:&err];
    }
  }
}

#if !(TARGET_OS_WATCH)

-(BOOL) isValidToUseApp {    
    BOOL isWithoutLogin = self.loginSource == LOGINSOURCE_WITHOUTLOGIN;
    return (isWithoutLogin || [self isValidToSendMessage]);
}

-(BOOL) isValidToSendMessage {
    BOOL result = [self nameSurname].length > 0
    && self.email.length > 0
    && [self.email isValidEmail];
    
    if(self.loginSource == LOGINSOURCE_WITHOUTLOGIN) {
        //Without login extra checks..
        return NO;
    } else if(self.loginSource == LOGINSOURCE_GOOGLE) {
        //Google extra checks..
    } else if (self.loginSource == LOGINSOURCE_FACEBOOK) {
        //Facebook extra checks...
    } else if (self.loginSource == LOGINSOURCE_PEPPERMINT) {
        result = result
        && self.name.length > 0
        && self.surname.length > 0
        && [self.password isPasswordLengthValid]
        && (self.jwt.length == 0
            || (self.jwt.length > 0
                && self.isEmailVerified))
        ;
    }
    return result;
}

#pragma mark - NameSurname

-(NSString*) nameSurname {
    NSString *nameSurname = [NSString stringWithFormat:@"%@ %@",
                             self.name.length > 0 ? self.name : @"",
                             self.surname.length > 0 ? self.surname : @""
                             ];
    nameSurname = [nameSurname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    nameSurname = [nameSurname capitalizedString];
    return nameSurname;
}

-(void) setNameSurname:(NSString*)nameSurname {
    self.name = nameSurname;
    self.surname = SURNAME_EMPTY;
}

#pragma mark - Guess Name From Device Name

-(void) guessNameFromDeviceName {
    if(self.nameSurname.length == 0) {
        NSString *deviceName = [UIDevice currentDevice].name;
        NSArray *names =  [self parseNamesFromDeviceName:deviceName];
        if(names.count > 0) {
            self.name = [names firstObject];
        }
    }
}

- (NSArray*) parseNamesFromDeviceName: (NSString *) deviceName
{
    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:@" '’\\"];
    NSArray* words = [deviceName componentsSeparatedByCharactersInSet:characterSet];
    NSMutableArray* names = [[NSMutableArray alloc] init];
    
    for (NSString *word in words)
    {
        if(![word localizedCaseInsensitiveContainsString:@"iPhone"]
           && ![word localizedCaseInsensitiveContainsString:@"iPod"]
           && ![word localizedCaseInsensitiveContainsString:@"iPad"]
           && ![word localizedCaseInsensitiveContainsString:@"mini"]
           && [word length] > 2
           )
        {
            NSString *newWord = [word stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[word substringToIndex:1] uppercaseString]];
            [names addObject:newWord];
        }
    }
    if ([names count] > 1)
    {
        NSInteger lastNameIndex = [names count] - 1;
        NSString* name = [names objectAtIndex:lastNameIndex];
        unichar lastChar = [name characterAtIndex:[name length] - 1];
        if (lastChar == 's')
        {
            [names replaceObjectAtIndex:lastNameIndex withObject:[name substringToIndex:[name length] - 1]];
        }
    }
    return names;
}

#pragma mark - ImageFilePath

-(NSURL*) imageFileUrl {
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"ProfileImage.png", nil];
    return [NSURL fileURLWithPathComponents:pathComponents];
}

-(NSString*) loginMethod {
    NSString *loginMethodString;
    if(self.loginSource == LOGINSOURCE_FACEBOOK) {
        loginMethodString = LOC(@"Facebook", @"Facebook");
    } else if(self.loginSource == LOGINSOURCE_GOOGLE) {
        loginMethodString = LOC(@"Google", @"Google");
    } else if(self.loginSource == LOGINSOURCE_PEPPERMINT) {
        loginMethodString = LOC(@"Peppermint", @"Peppermint");
    }
    return loginMethodString;
}

-(void) clearSender {

#warning "Implement a better approach to clean all properties"
    if(self.loginSource == LOGINSOURCE_GOOGLE) {
        [[PeppermintGIdSignIn GIdSignInInstance] disconnect];
    }
    
    self.name = NIL_TEXT;
    self.surname = NIL_TEXT;
    self.email = NIL_TEXT;
    self.password = NIL_TEXT;
    self.imageData = [NSData new];
    self.loginSource = -1;
    self.jwt = NIL_TEXT;
    self.isEmailVerified = NO;
    self.accountId = NIL_TEXT;
    
    self.recorderJwt = NIL_TEXT;
    self.recorderId = NIL_TEXT;
    self.recorderClientId = NIL_TEXT;
    self.recorderKey = NIL_TEXT;
    self.exchangedJwt = NIL_TEXT;
    self.gcmToken = nil; // Maybe the app will not be restarted, so we should call [gcm init] manually. [recorder init] will need gcmToken
    self.isAccountSetUpWithRecorder = NO;
    
    defaults_remove(DEFAULTS_KEY_CACHED_SENDVOCIEMESSAGE_MODEL);
    defaults_remove(DEFAULTS_KEY_DONT_SHOW_SMS_WARNING);
    defaults_remove(DEFAULTS_KEY_PREVIOUS_RECORDING_LENGTH);
    defaults_remove(DEFAULTS_EMAIL_UID_HOLDER);
    defaults_remove(DEFAULTS_SYNC_DATE_HOLDER);
    defaults_remove(DEFAULTS_TRANSCRIPTION_LANG_CODE);
    
    [[AppDelegate Instance] cleanDatabase];
    [self save];
}

-(BOOL) isInMailVerificationProcess {
    return self.loginSource == LOGINSOURCE_PEPPERMINT
    && self.jwt.length > 0
    && !self.isEmailVerified;
}

-(void) verifyEmail {
    self.isEmailVerified = YES;
    [self save];
}

-(BOOL) isUserStillLoggedIn {
    BOOL isUserStillLoggedIn = [PeppermintMessageSender sharedInstance].email.length > 0;
    return isUserStillLoggedIn;
}

#endif

@end
