//
//  PeppermintMessageSender.m
//  Peppermint
//
//  Created by Okan Kurtulus on 20/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "PeppermintMessageSender.h"
#import "A0SimpleKeychain.h"

#define KEY @"PeppermintMessageSenderJson"


@import WatchConnectivity;


@interface PeppermintMessageSender () <WCSessionDelegate>

@end

@implementation PeppermintMessageSender

#if !(TARGET_OS_WATCH)
+ (instancetype) sharedInstance {
  return SHARED_INSTANCE([self savedSender]);
}
#else
+ (instancetype) sharedInstance {
  return [self savedSender];
}
#endif

+(instancetype)savedSender {
    NSError *error;
    PeppermintMessageSender *sender;
    NSString *jsonString = [[A0SimpleKeychain keychain] stringForKey:KEYCHAIN_MESSAGE_SENDER];
 
    BOOL isJsonStringValid = jsonString.length > 0;
    if(isJsonStringValid) {
        NSLog(@"\n\n\nCreate from Json: %@\n\n\n", jsonString);
        sender = [[PeppermintMessageSender alloc] initWithString:jsonString error:&error];
        if(error) {
            NSLog(@"JSON init Error : %@", error);
            isJsonStringValid = NO;
        }
    }    
    if(!isJsonStringValid) {
        sender = [PeppermintMessageSender new];
#if !(TARGET_OS_WATCH)
      [sender clearSender];
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
  
  if (NSClassFromString(@"WCSession")) {
    if ([WCSession isSupported]) {
      [[WCSession defaultSession] updateApplicationContext:@{@"user":[self toJSONString]} error:nil];
    }
  }
#if !(TARGET_OS_WATCH)
    [self.imageData writeToURL:[self imageFileUrl] atomically:YES];
#endif
}

#if !(TARGET_OS_WATCH)

-(BOOL) isValid {
    BOOL result = self.nameSurname.length > 0
    && self.email.length > 0
    && [self.email isValidEmail];
    
    if(self.loginSource == LOGINSOURCE_GOOGLE) {
        //Google extra checks..
    } else if (self.loginSource == LOGINSOURCE_FACEBOOK) {
        //Facebook extra checks...
    } else if (self.loginSource == LOGINSOURCE_PEPPERMINT) {
        result = result
        && self.password.length > 0
        && (self.jwt.length == 0
            || (self.jwt.length > 0
                && self.isEmailVerified))
        ;
    }
    return result;
}

#pragma mark - Guess Name From Device Name

-(void) guessNameFromDeviceName {
    if(self.nameSurname.length == 0) {
        NSString *deviceName = [UIDevice currentDevice].name;
        NSArray *names =  [self parseNamesFromDeviceName:deviceName];
        if(names.count > 0) {
            self.nameSurname = [names firstObject];
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
    self.nameSurname = @"";
    self.email = @"";
    self.password = @"";
    self.imageData = nil;
    self.loginSource = -1;
    self.jwt = @"";
    self.isEmailVerified = NO;
    [self save];
}

-(BOOL) isInMailVerificationProcess {
    return self.loginSource == LOGINSOURCE_PEPPERMINT
    && self.jwt.length > 0
    && !self.isEmailVerified;
}

#endif

@end
