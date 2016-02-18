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
        scheduledPeppermintContact = nil;
    }
    return self;
}

-(void) scheduleAutoPlayForPeppermintContact:(PeppermintContact*)peppermintContact {
    scheduledPeppermintContact = peppermintContact;
}

-(BOOL) isScheduledForPeppermintContactWithNameSurname:(NSString*)nameSurname email:(NSString*)email {
    BOOL result = NO;
    if(scheduledPeppermintContact
       && [scheduledPeppermintContact.nameSurname.lowercaseString isEqualToString:nameSurname.lowercaseString]
       && [scheduledPeppermintContact.communicationChannelAddress.lowercaseString isEqualToString:email.lowercaseString]) {
        scheduledPeppermintContact = nil;
        result = YES;
    }
    return result;
}

@end
