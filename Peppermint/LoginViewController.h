//
//  LoginViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseLoginViewController.h"

@interface LoginViewController : BaseLoginViewController <UITableViewDataSource, UITableViewDelegate, LoginTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *withoutLoginLabel;

@end
