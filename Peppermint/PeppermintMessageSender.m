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

@implementation PeppermintMessageSender

-(id) init {
    self = [super init];
    if(self) {
        self.nameSurname = (NSString*) defaults_object(DEFAULTS_KEY_SENDER_NAMESURNAME);
        self.email = (NSString*) defaults_object(DEFAULTS_KEY_SENDER_EMAIL);
        self.password = (NSString*) defaults_object(DEFAULTS_KEY_SENDER_PASSWORD);
        self.imageData = [NSData dataWithContentsOfURL:[self imageFileUrl]];
        self.loginSource = ((NSNumber*)defaults_object(DEFAULTS_KEY_SENDER_LOGIN_SOURCE)).intValue;
        [self guessNameFromDeviceName];
    }
    return self;
}

-(void) save {
    defaults_set_object(DEFAULTS_KEY_SENDER_LOGIN_SOURCE, [NSNumber numberWithInt:self.loginSource]);
    defaults_set_object(DEFAULTS_KEY_SENDER_NAMESURNAME, self.nameSurname);
    defaults_set_object(DEFAULTS_KEY_SENDER_EMAIL, self.email);
    defaults_set_object(DEFAULTS_KEY_SENDER_PASSWORD, self.password);
    
    [self.imageData writeToURL:[self imageFileUrl] atomically:YES];
}

-(BOOL) isValid {    
    return self.nameSurname.length > 0
    && self.email.length > 0
    && [self.email isValidEmail]
    && self.password.length > 0;
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

@end
