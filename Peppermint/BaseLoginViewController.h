//
//  BaseLoginViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 25/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginNavigationViewController.h"
#import "LoginModel.h"
#import "ConnectionModel.h"

@interface BaseLoginViewController : BaseViewController
@property (strong, nonatomic) NSDate *referanceDate;

-(void) showInternetIsNotReachableError;
-(void) withoutLoginLabelPressed:(id) sender;
@end
