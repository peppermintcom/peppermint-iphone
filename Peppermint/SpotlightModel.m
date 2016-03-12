//
//  SpotlightModel.m
//  Peppermint
//
//  Created by Yan Saraev on 11/18/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "SpotlightModel.h"
#import "FastReplyModel.h"

@import CoreSpotlight;
@import MobileCoreServices;

NSString * const CSSearchItemIdentifierJoinString = @".PPM.";

@implementation SpotlightModel

+ (void)createSearchableItemForContact:(PeppermintContact *)contact {
  if (!NSClassFromString(@"CSSearchableIndex")) {
    return; //only ios9
  }
  
  if (![CSSearchableIndex isIndexingAvailable]) {
    return; //not all devices support indexing
  }
  
  CSSearchableItemAttributeSet *attibuteSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(__bridge NSString *)kUTTypeImage];
  attibuteSet.title = [NSString stringWithFormat:@"%@ - %@", contact.nameSurname, contact.communicationChannelAddress];
  attibuteSet.contentDescription = LOC(@"Touch to send an audio message", nil);
  attibuteSet.keywords = @[@"Peppermint", contact.nameSurname, contact.communicationChannelAddress, @"email"];
  
  UIImage *image = nil;
  if (contact.avatarImage) {
    image = contact.avatarImage;
  } else {
    image = [UIImage imageNamed:@"avatar_empty"];
  }
  
  NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
  attibuteSet.thumbnailData = imageData;
    
  NSString * uniqueKey = [@[contact.nameSurname, contact.communicationChannelAddress] componentsJoinedByString:CSSearchItemIdentifierJoinString];
  
  CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:uniqueKey
                                                             domainIdentifier:@"com.peppemint"
                                                                 attributeSet:attibuteSet];
  if (item) {
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:^(NSError * _Nullable error) {
      if (!error) {
        //NSLog(@"Search item indexed");
      }
    }];
  }
}

+ (BOOL)handleSearchItemUniqueIdentifier:(NSString *)uniqueId {
  //our unique id has @"%@.PPM.%@" format
  NSArray * components = [uniqueId componentsSeparatedByString:CSSearchItemIdentifierJoinString];
  NSString * nameSurname = [components firstObject];
  NSString * email = [components lastObject];
  
  if (nameSurname && email) {
      return [[FastReplyModel sharedInstance] setFastReplyContactWithNameSurname:nameSurname email:email];
  }
  
  return NO;
}


@end
