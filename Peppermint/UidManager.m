//
//  UidManager.m
//  Peppermint
//
//  Created by Okan Kurtulus on 23/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "UidManager.h"
#import "UidHolder.h"

#define SEPERATOR   @"_|_"

@implementation UidManager {
    UidHolder *uidHolder;
}

+ (instancetype) sharedInstance {
    return SHARED_INSTANCE( [[self alloc] initShared] );
}

-(id) init {
    NSAssert(false, @"This model instance is singleton so should not be inited - %@", self);
    return nil;
}

-(id) initShared {
    self = [super init];
    if(self) {
        [self refreshUidHolder];
    }
    return self;
}

-(void) refreshUidHolder {
    NSError *error;
    NSString *jsonText = defaults_object(DEFAULTS_EMAIL_UID_HOLDER);
    uidHolder = [[UidHolder alloc] initWithString:jsonText error:&error];
    if(error) {
        uidHolder = [UidHolder new];
        uidHolder.accountsUdidDictionary = [NSMutableDictionary new];
    }
}

-(NSString*) keyForUsername:(NSString*) sessionUserName folder:(NSString*) folderName {
    NSString *key = [NSString stringWithFormat:@"%@%@%@"
                     , sessionUserName
                     , SEPERATOR
                     , folderName];
    return key;
}

-(NSNumber*) getUidForUsername:(NSString*) sessionUserName folder:(NSString*) folderName {
    NSString *key = [self keyForUsername:sessionUserName folder:folderName];
    [self refreshUidHolder];
    NSNumber *uidNumber = [uidHolder.accountsUdidDictionary valueForKey:key];
    if(!uidNumber) {
        uidNumber = @0;
    }
    return uidNumber;
}

-(void) save:(NSNumber*)uidNumber forUsername:(NSString*)sessionUserName folder:(NSString*) folderName {
    NSString *key = [self keyForUsername:sessionUserName folder:folderName];
    [uidHolder.accountsUdidDictionary setValue:uidNumber forKey:key];
    defaults_set_object(DEFAULTS_EMAIL_UID_HOLDER, [uidHolder toJSONString]);
}

@end
