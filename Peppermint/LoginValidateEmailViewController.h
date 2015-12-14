//
//  LoginValidateEmailViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 09/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginModel.h"

@interface LoginValidateEmailViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, LoginValidateEmailTableViewCellDelegate, AccountModelDelegate>

@property (weak, nonatomic) LoginModel *loginModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;

-(void) checkIfAccountIsVerified;

@end
