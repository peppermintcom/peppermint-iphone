//
//  LoginWithEmailViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginModel.h"

@interface LoginWithEmailViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, LoginTextFieldTableViewCellDelegate>
@property (weak, nonatomic) LoginModel *loginModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;

@end
