//
//  LoginWithEmailViewController.h
//  Peppermint
//
//  Created by Yan Saraev on 11/24/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"

@class LoginModel;

@interface LoginWithEmailViewController : UITableViewController

@property (strong, nonatomic) LoginModel *loginModel;

- (IBAction)textFieldDidChange:(UITextField *)textField;

@end
