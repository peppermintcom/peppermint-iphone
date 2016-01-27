//
//  BaseTableViewController.h
//  Peppermint
//
//  Created by Yan Saraev on 11/30/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataTableViewController.h"

@interface BaseTableViewController : StaticDataTableViewController

-(void) operationFailure:(NSError*) error;

@end