//
//  ContactsViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ContactsModel.h"
#import "RecentContactsModel.h"
#import <REMenu/REMenu.h>

@interface ContactsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ContactsModelDelegate, RecentContactsModelDelegate, SearchMenuTableViewCellDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) ContactsModel *contactsModel;
@property (strong, nonatomic) RecentContactsModel *recentContactsModel;
@property (strong, nonatomic) REMenu *searchMenu;

@property (weak, nonatomic) IBOutlet UIView *searchMenuView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchContactsTextField;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

-(IBAction)searchButtonPressed:(id)sender;

@end
