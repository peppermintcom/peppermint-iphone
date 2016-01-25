//
//  PeppermintContact.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "PeppermintContact.h"

#if !(TARGET_OS_WATCH)
#import "SpotlightModel.h"
#endif

@implementation PeppermintContact

- (void)encodeWithCoder:(NSCoder *)encoder {
  //Encode properties, other class variables, etc
  [encoder encodeObject:@(self.communicationChannel) forKey:@"communicationChannel"];
  [encoder encodeObject:self.communicationChannelAddress forKey:@"communicationChannelAddress"];
  [encoder encodeObject:self.nameSurname forKey:@"nameSurname"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  if((self = [super init])) {
    //decode properties, other class vars
    self.nameSurname = [decoder decodeObjectForKey:@"nameSurname"];
    self.communicationChannelAddress = [decoder decodeObjectForKey:@"communicationChannelAddress"];
    self.communicationChannel = [[decoder decodeObjectForKey:@"communicationChannel"] intValue];
  }
  return self;
}

#if !(TARGET_OS_WATCH)
- (void)addToCoreSpotlightSearch {
  [SpotlightModel createSearchableItemForContact:self];
}
#endif

- (BOOL) equals:(PeppermintContact*)peppermintContact {
    return ([self.nameSurname isEqualToString:peppermintContact.nameSurname]
            && self.communicationChannel == peppermintContact.communicationChannel
            && [self.communicationChannelAddress isEqualToString:peppermintContact.communicationChannelAddress]);
}

-(BOOL) isIdenticalForImage:(PeppermintContact*) contactToCompare {
    return self
    && contactToCompare
    && self.communicationChannel == contactToCompare.communicationChannel
    && [self.communicationChannelAddress isEqualToString:contactToCompare.communicationChannelAddress];
}

+ (PeppermintContact *)peppermintContactWithData:(NSData *)data {
  PeppermintContact *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  return object;
}

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[PeppermintContact class]]) {
    return NO;
  }
  
  PeppermintContact * other = (PeppermintContact *)object;
  return other.communicationChannel == self.communicationChannel && [self.communicationChannelAddress isEqualToString:other.communicationChannelAddress] && [self.nameSurname isEqualToString:other.nameSurname];
}

- (NSData *)archivedRootData {
  NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
  return encodedObject;
}

@end
