//
//  LoginSupplyEmailViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 21/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"

@class LoginModel;

@interface LoginSupplyEmailViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) LoginModel *loginModel;

@end
