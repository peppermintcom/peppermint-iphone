//
//  MailClientContactsViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 28/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseReSideMenuContentViewController.h"
#import "RecentContactsModel.h"

@interface MailClientContactsViewController : BaseReSideMenuContentViewController <UITableViewDelegate, UITableViewDataSource, RecentContactsModelDelegate>
@property (strong, nonatomic) RecentContactsModel *recentContactsModel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchContactsTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *whiteEllipseView;

+(instancetype) createInstance;

@end
