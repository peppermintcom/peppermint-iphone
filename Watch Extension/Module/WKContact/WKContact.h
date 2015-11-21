//
//  WKContact.h
//  Peppermint
//
//  Created by Yan Saraev on 11/20/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PeppermintContact;

@interface WKContact : NSObject

+ (void)allContacts:(void (^)(NSArray <PeppermintContact *> * contacts))block;

@end
