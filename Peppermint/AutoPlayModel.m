//
//  AutoPlayModel.m
//  Peppermint
//
//  Created by Okan Kurtulus on 18/02/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "AutoPlayModel.h"
#import "PeppermintContact.h"

@implementation AutoPlayModel {
    PeppermintContact *scheduledPeppermintContact;
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
        [self clearScheduledPeppermintContact];
    }
    return self;
}

-(void) scheduleAutoPlayForPeppermintContact:(PeppermintContact*)peppermintContact {
    scheduledPeppermintContact = peppermintContact;
}

-(BOOL) isScheduledForPeppermintContactWithEmail:(NSString*)email {
    BOOL result = NO;
    if(scheduledPeppermintContact
       && [scheduledPeppermintContact.communicationChannelAddress.lowercaseString isEqualToString:email.lowercaseString]) {
        result = YES;
    }
    return result;
}

-(void) clearScheduledPeppermintContact {
    scheduledPeppermintContact = nil;
}

@end
