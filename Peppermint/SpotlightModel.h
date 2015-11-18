//
//  SpotlightModel.h
//  Peppermint
//
//  Created by Yan Saraev on 11/18/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseModel.h"

@class PeppermintContact;

@interface SpotlightModel : BaseModel

+ (void)createSearchableItemForContact:(PeppermintContact *)contact;
+ (BOOL)handleSearchItemUniqueIdentifier:(NSString *)uniqueId;

@end
