//
//  ContactsViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseReSideMenuContentViewController.h"
#import "ContactsModel.h"
#import "RecentContactsModel.h"
#import "FastRecordingView.h"
#import "FoggyRecordingView.h"
#import "TutorialView.h"
#import "ChatEntrySyncModel.h"

#define CELL_TAG_ALL_CONTACTS           1
#define CELL_TAG_RECENT_CONTACTS        2
#define CELL_TAG_EMAIL_CONTACTS         3
#define CELL_TAG_SMS_CONTACTS           4

@interface ContactsViewController : BaseReSideMenuContentViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ContactsModelDelegate, RecentContactsModelDelegate, SearchMenuTableViewCellDelegate, UIAlertViewDelegate, ContactTableViewCellDelegate, RecordingViewDelegate, ContactInformationTableViewCellDelegate>
@property (strong, nonatomic) ContactsModel *contactsModel;
@property (strong, nonatomic) RecentContactsModel *recentContactsModel;
@property (strong, nonatomic) ChatEntrySyncModel *chatEntrySyncModel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchContactsTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *sendingIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *sendingInformationLabel;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@property (weak, nonatomic) IBOutlet UIView *holdToRecordInfoView;
@property (weak, nonatomic) IBOutlet UILabel *holdToRecordInfoViewLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *holdToRecordInfoViewYValueConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cancelMessageSendingButton;
@property (weak, nonatomic) IBOutlet UIView *whiteEllipseView;
@property (strong, nonatomic) RecordingView *recordingView;
@property (strong, nonatomic) TutorialView *tutorialView;

-(void) resetUserInterfaceWithActiveCellTag:(int)newCellTag;
-(IBAction)messageCancelButtonPressed:(id)sender;
-(void) refreshContacts;
-(void) scheduleNavigateToChatEntryWithEmail:(NSString*) email;

@end