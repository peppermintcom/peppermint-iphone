//
//  BaseModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !(TARGET_OS_WATCH)
#import "Tolo.h"
#import "Events.h"
#endif

@protocol BaseModelDelegate <NSObject>
@required
-(void) operationFailure:(NSError*) error;
@end

@interface BaseModel : NSObject

@end
