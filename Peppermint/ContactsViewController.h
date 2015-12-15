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
#import "FastRecordingView.h"
#import "ReSideMenuContainerViewController.h"
#import "TutorialView.h"

@interface ContactsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ContactsModelDelegate, RecentContactsModelDelegate, SearchMenuTableViewCellDelegate, UIAlertViewDelegate, ContactTableViewCellDelegate, RecordingViewDelegate, ContactInformationTableViewCellDelegate>
@property (strong, nonatomic) ContactsModel *contactsModel;
@property (strong, nonatomic) RecentContactsModel *recentContactsModel;
@property (strong, nonatomic) REMenu *searchMenu;

@property (weak, nonatomic) IBOutlet UIView *searchMenuView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchContactsTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *sendingIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *sendingInformationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendingImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@property (weak, nonatomic) IBOutlet UIView *holdToRecordInfoView;
@property (weak, nonatomic) IBOutlet UILabel *holdToRecordInfoViewLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *holdToRecordInfoViewYValueConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *searchSourceIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelMessageSendingButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelMessageButtonWidthConstraint;
@property (strong, nonatomic) RecordingView *recordingView;
@property (weak, nonatomic) ReSideMenuContainerViewController *reSideMenuContainerViewController;
@property (strong, nonatomic) TutorialView *tutorialView;

-(IBAction)searchButtonPressed:(id)sender;
-(IBAction)messageCancelButtonPressed:(id)sender;
-(void) refreshContacts;

@end