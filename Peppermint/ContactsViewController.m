//
//  ContactsViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsViewController.h"
#import "RecordingViewController.h"
#import "SendVoiceMessageEmailModel.h"

#define SEGUE_RECORDING_VIEW_CONTROLLER @"RecordingViewControllerSegue"

#define CELL_TAG_ALL_CONTACTS       1
#define CELL_TAG_RECENT_CONTACTS    2
#define CELL_TAG_EMAIL_CONTACTS     3
#define CELL_TAG_SMS_CONTACTS       4

@interface ContactsViewController ()

@end

@implementation ContactsViewController {
    UIAlertView *contactsAlertView;
    BOOL canDeviceSendEmail;
    NSUInteger activeCellTag;
    NSUInteger cachedActiveCellTag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    contactsAlertView = nil;
    canDeviceSendEmail = [SendVoiceMessageEmailModel canDeviceSendEmail];    
    if(!self.contactsModel) {
        self.contactsModel = [ContactsModel new];
        self.contactsModel.delegate = self;
        [self.contactsModel setup];
    }
    self.recentContactsModel = [RecentContactsModel new];
    self.recentContactsModel.delegate = self;
    self.searchContactsTextField.text = self.contactsModel.filterText;
    self.searchContactsTextField.placeholder = LOC(@"Search for Contacts", @"Placeholder text");
    self.searchContactsTextField.tintColor = [UIColor textFieldTintGreen];
    self.searchContactsTextField.delegate = self;
    self.searchContactsTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self initSearchMenu];
    self.loadingView.hidden = YES;
    activeCellTag = CELL_TAG_ALL_CONTACTS;
    cachedActiveCellTag = CELL_TAG_ALL_CONTACTS;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.contactsModel = nil;
    self.recentContactsModel = nil;
    self.searchMenu = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.loadingView.hidden = NO;
    self.searchContactsTextField.text = self.contactsModel.filterText = @"";
    activeCellTag = CELL_TAG_RECENT_CONTACTS;
    [self.recentContactsModel refreshRecentContactList];
    [self registerKeyboardActions];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchContactsTextField becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self deRegisterKeyboardActions];
}

#pragma mark - ContactList Logic

- (NSArray*) activeContactList {
    NSArray *activeContactList = nil;
    
    if(activeCellTag == CELL_TAG_RECENT_CONTACTS) {
        activeContactList = self.recentContactsModel.contactList;
    } else if (activeCellTag == CELL_TAG_ALL_CONTACTS)   {
        activeContactList = self.contactsModel.contactList;
    } else if (activeCellTag == CELL_TAG_EMAIL_CONTACTS) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.communicationChannel == %d", CommunicationChannelEmail];
        activeContactList = [self.contactsModel.contactList filteredArrayUsingPredicate:predicate];
    } else if (activeCellTag == CELL_TAG_SMS_CONTACTS) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.communicationChannel == %d", CommunicationChannelSMS];
        activeContactList = [self.contactsModel.contactList filteredArrayUsingPredicate:predicate];
    } else {
        activeContactList = [NSArray new];
    }
    return activeContactList;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self activeContactList].count == 0 ? 1 : [self activeContactList].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *preparedCell = nil;
    if([self activeContactList].count == 0) {
        EmptyResultTableViewCell *cell = [CellFactory cellEmptyResultTableViewCellFromTable:tableView forIndexPath:indexPath];
        [cell setVisibiltyOfExplanationLabels:self.contactsModel.filterText.length > 0];
        preparedCell = cell;
    } else if (indexPath.row < [self activeContactList].count) {
        ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath];
        PeppermintContact *peppermintContact = [[self activeContactList] objectAtIndex:indexPath.row];
        if(peppermintContact.avatarImage) {
            cell.avatarImageView.image = peppermintContact.avatarImage;
        } else {
            cell.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
        }        
        cell.contactNameLabel.text = peppermintContact.nameSurname;
        cell.contactViaInformationLabel.text = peppermintContact.communicationChannelAddress;
        preparedCell = cell;
    }
    return preparedCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if([self activeContactList].count == 0) {
        height = CELL_HEIGHT_EMPTYRESULT_TABLEVIEWCELL;
    } else {
        height = CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
    }
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self activeContactList].count > indexPath.row) {
        PeppermintContact *selectedContact = [[self activeContactList] objectAtIndex:indexPath.row];
        [self.searchContactsTextField resignFirstResponder];
        if([self shouldPerformSegueWithIdentifier:SEGUE_RECORDING_VIEW_CONTROLLER sender:selectedContact]) {
            [self performSegueWithIdentifier:SEGUE_RECORDING_VIEW_CONTROLLER sender:selectedContact];
        }
    }
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(![string isEqual:@"\n"]) {
        [self.searchMenu close];
        self.contactsModel.filterText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = self.contactsModel.filterText;
        
        if(textField.text.length > 0
           && activeCellTag == CELL_TAG_RECENT_CONTACTS) {
            cachedActiveCellTag = CELL_TAG_RECENT_CONTACTS;
            activeCellTag = CELL_TAG_ALL_CONTACTS;
        } else if (textField.text.length == 0
                   &&cachedActiveCellTag == CELL_TAG_RECENT_CONTACTS ) {
            cachedActiveCellTag = CELL_TAG_ALL_CONTACTS;
            activeCellTag = CELL_TAG_RECENT_CONTACTS;
        }
        
        if(activeCellTag == CELL_TAG_RECENT_CONTACTS) {
            [self.recentContactsModel refreshRecentContactList];
        } else {
            [self.contactsModel refreshContactList];
        }
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.searchMenu close];
    return YES;
}

#pragma mark - ContactsModelDelegate

-(void) contactsAccessRightsAreNotSupplied {
    [self.searchContactsTextField resignFirstResponder];
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Contacts access rights explanation", @"Directives to give access rights") ;
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    NSString *settingsButtonTitle = LOC(@"Settings", @"Settings Message");
    contactsAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:settingsButtonTitle, nil];
    [contactsAlertView show];

}

-(void) contactListRefreshed {
    self.loadingView.hidden = YES;
    [self.tableView reloadData];
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactSavedSucessfully:(PeppermintContact*) recentContact {
    NSLog(@"Contact saved successfully. %@", recentContact.nameSurname);
}

-(void) recentPeppermintContactsRefreshed {
    self.loadingView.hidden = YES;
    [self.tableView reloadData];
}

#pragma mark - SearchButton

-(IBAction)searchButtonPressed:(id)sender {
    if(!self.searchMenu.isOpen) {
        self.searchMenuView.hidden = NO;
        [self.searchMenu showInView:self.searchMenuView];
    } else {        
        [self.searchMenu close];
    }
}

#pragma mark - SearchMenu

-(REMenuItem*) createMenuItemWithTitle:(NSString*)title icon:(NSString*)icon iconHighlighted:(NSString*)iconHightlighted cellTag:(NSUInteger)cellTag {
    SearchMenuTableViewCell *cellView = [CellFactory cellSearchMenuTableViewCellFromTable:nil forIndexPath:nil];
    cellView.titleLabel.text = title;
    cellView.iconImageName = icon;
    cellView.iconHighlightedImageName = iconHightlighted;
    cellView.cellTag = cellTag;
    cellView.delegate = self;
    [cellView setSelected:NO];
    REMenuItem *reMenuItem = [[REMenuItem alloc] initWithCustomView:cellView];
    return reMenuItem;
}

-(void) initSearchMenu {
    REMenuItem *allContactsMenuItem = [self createMenuItemWithTitle:LOC(@"All Contacts", @"Title")
                                                               icon:@"icon_search"
                                                    iconHighlighted:@"icon_search_pressed"
                                                                cellTag:CELL_TAG_ALL_CONTACTS];
    
    REMenuItem *recentContactsMenuItem = [self createMenuItemWithTitle:LOC(@"Recent Contacts", @"Title")
                                                                 icon:@"icon_star"
                                                      iconHighlighted:@"icon_star_pressed"
                                                                  cellTag:CELL_TAG_RECENT_CONTACTS];
    
    REMenuItem *emailContactsMenuItem = [self createMenuItemWithTitle:LOC(@"Email Contacts", @"Title")
                                                               icon:@"icon_email"
                                                    iconHighlighted:@"icon_email_pressed"
                                                                cellTag:CELL_TAG_EMAIL_CONTACTS];
    
    REMenuItem *smsContactsMenuItem = [self createMenuItemWithTitle:LOC(@"Phone Contacts", @"Title")
                                                                 icon:@"icon_phone"
                                                      iconHighlighted:@"icon_phone_pressed"
                                                                  cellTag:CELL_TAG_SMS_CONTACTS];
    
    self.searchMenu = [[REMenu alloc] initWithItems:@[allContactsMenuItem,
                                                      recentContactsMenuItem,
                                                      emailContactsMenuItem,
                                                      smsContactsMenuItem]];
    
    self.searchMenu.bounce = NO;
    self.searchMenu.cornerRadius = 5;
    self.searchMenu.borderWidth = 0;
    self.searchMenu.separatorHeight = 0;
    self.searchMenu.separatorColor = [UIColor cellSeperatorGray];
    self.searchMenu.closeOnSelection = YES;
    __weak __typeof__(self) weakSelf = self;
    self.searchMenu.closeCompletionHandler = ^{
        weakSelf.searchMenuView.hidden = YES;
    };
}

#pragma mark - SearchMenuTableViewCellDelegate

-(void)cellSelectedWithTag:(NSUInteger) cellTag {
    [self.searchMenu close];
    self.searchContactsTextField.text = self.contactsModel.filterText = @"";
    activeCellTag = cellTag;
    if(cellTag == CELL_TAG_RECENT_CONTACTS) {
        [self.recentContactsModel refreshRecentContactList];
    } else {
        [self.contactsModel refreshContactList];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView == contactsAlertView) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self redirectToSettingsPageForPermission];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Keyboard Actions

-(void) registerKeyboardActions {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void) deRegisterKeyboardActions {
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillHideNotification object: nil];
}

-(void) keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    CGFloat keyboardHeight = 0;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait
        || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        keyboardHeight = keyboardBounds.size.height;
    } else {
        keyboardHeight = keyboardBounds.size.width;
    }
    
    [self.tableView layoutIfNeeded];
    self.tableViewBottomConstraint.constant = keyboardHeight;
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView layoutIfNeeded];
    }];
}

-(void) keyboardWillHide:(NSNotification *)notification {
    [self.tableView layoutIfNeeded];
    self.tableViewBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView layoutIfNeeded];
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_RECORDING_VIEW_CONTROLLER]) {
        RecordingViewController *rvc = (RecordingViewController*)segue.destinationViewController;
        PeppermintContact *selectedContact = (PeppermintContact*)sender;
        
        if(selectedContact.communicationChannel == CommunicationChannelEmail) {
            SendVoiceMessageEmailModel *sendVoiceMessageEmailModel = [SendVoiceMessageEmailModel new];
            sendVoiceMessageEmailModel.selectedPeppermintContact = selectedContact;
            sendVoiceMessageEmailModel.delegate = rvc;
            rvc.sendVoiceMessageModel = sendVoiceMessageEmailModel;
        } else if (selectedContact.communicationChannel == CommunicationChannelSMS) {
            NSLog(@"SMS functionality is not implemented yet");
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL result = YES;    
    if([identifier isEqualToString:SEGUE_RECORDING_VIEW_CONTROLLER]) {
        PeppermintContact *selectedContact = (PeppermintContact*)sender;        
        if(selectedContact.communicationChannel == CommunicationChannelEmail) {
            result = canDeviceSendEmail;
            if(!result) {
                NSString *title = LOC(@"Information", @"Information");
                NSString *message = LOC(@"Please add an email account", @"Email service info");
                NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
                [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
            }
        } else if (selectedContact.communicationChannel == CommunicationChannelSMS) {
            result = NO;
            NSString *title = LOC(@"Information", @"Information");
            NSString *message = LOC(@"SMS is not implemented", @"SMS implementation info");
            NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
            [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
        }
    }
    return result;
}

@end
