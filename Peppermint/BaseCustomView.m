//
//  BaseCustomView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 16/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseCustomView.h"
#import "AppDelegate.h"

@implementation BaseCustomView

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
    [AppDelegate handleError:error];
}

@end
