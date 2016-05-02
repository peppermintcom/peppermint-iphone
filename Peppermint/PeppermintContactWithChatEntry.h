//
//  PeppermintContactWithChatEntry.h
//  Peppermint
//
//  Created by Okan Kurtulus on 30/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeppermintContact.h"
#import "PeppermintChatEntry.h"

@interface PeppermintContactWithChatEntry : NSObject
@property (strong, nonatomic) PeppermintContact *peppermintContact;
@property (strong, nonatomic) PeppermintChatEntry *peppermintChatEntry;
@end
