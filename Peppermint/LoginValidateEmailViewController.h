//
//  LoginValidateEmailViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 09/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginModel.h"
#import "ContactSupportModel.h"

@interface LoginValidateEmailViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, AccountModelDelegate, LoginTableViewCellDelegate, ContactSupportModelDelegate>
@property (weak, nonatomic) LoginModel *loginModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void) checkIfAccountIsVerified;

@end
