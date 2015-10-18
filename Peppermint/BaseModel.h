//
//  BaseModel.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tolo.h"
#import "Events.h"

@protocol BaseModelDelegate <NSObject>
@required
-(void) operationFailure:(NSError*) error;
@end

@interface BaseModel : NSObject

@end
