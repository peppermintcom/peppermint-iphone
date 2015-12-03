//
//  BaseTableViewController.m
//  Peppermint
//
//  Created by Yan Saraev on 11/30/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewController.h"
#import "AppDelegate.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

#pragma mark - BaseModelDelegate

-(void) operationFailure:(NSError*) error {
  [AppDelegate handleError:error];
}

@end
