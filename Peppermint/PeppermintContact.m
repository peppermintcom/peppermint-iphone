//
//  PeppermintContact.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "PeppermintContact.h"
#import "SpotlightModel.h"

@implementation PeppermintContact

- (void)addToCoreSpotlightSearch {
  [SpotlightModel createSearchableItemForContact:self];
}

- (BOOL) equals:(PeppermintContact*)peppermintContact {
    return ([self.nameSurname isEqualToString:peppermintContact.nameSurname]
            && self.communicationChannel == peppermintContact.communicationChannel
            && [self.communicationChannelAddress isEqualToString:peppermintContact.communicationChannelAddress]);
}

@end
