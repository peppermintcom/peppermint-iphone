//
//  ContactsViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ContactsModel.h"

@interface ContactsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ContactsModelDelegate>
@property (strong, nonatomic) ContactsModel *contactsModel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchContactsTextField;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@end
