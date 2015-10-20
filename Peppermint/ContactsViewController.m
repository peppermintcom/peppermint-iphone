//
//  ContactsViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsViewController.h"
#import "RecordingViewController.h"
#import "SendVoiceMessageMandrillModel.h"

#define SEGUE_RECORDING_VIEW_CONTROLLER         @"RecordingViewControllerSegue"

#define CELL_TAG_ALL_CONTACTS       1
#define CELL_TAG_RECENT_CONTACTS    2
#define CELL_TAG_EMAIL_CONTACTS     3
#define CELL_TAG_SMS_CONTACTS       4

#define ALLOWED_CHARS @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@."
#define MESSAGE_SENDING_DURATION   2

#define SENDING_ICON_HEIGHT     15
#define SENT_ICON_HEIGHT        20

#define ANIM_TIME               0.3
#define WARN_TIME               1.5

@interface ContactsViewController ()

@end

@implementation ContactsViewController {
    NSUInteger activeCellTag;
    NSUInteger cachedActiveCellTag;
    NSCharacterSet *unwantedCharsSet;
    NSUInteger activeSendingCount;
    BOOL isScrolling;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.contactsModel) {
        self.contactsModel = [ContactsModel new];
        self.contactsModel.delegate = self;
        [self.contactsModel setup];
    }
    self.recentContactsModel = [RecentContactsModel new];
    self.recentContactsModel.delegate = self;
    self.searchContactsTextField.font = [UIFont openSansFontOfSize:14];
    self.searchContactsTextField.text = self.contactsModel.filterText;
    self.searchContactsTextField.placeholder = LOC(@"Search for Contacts", @"Placeholder text");
    self.searchContactsTextField.tintColor = [UIColor textFieldTintGreen];
    self.searchContactsTextField.delegate = self;
    self.searchContactsTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self initSearchMenu];
    self.loadingView.hidden = YES;
    activeCellTag = CELL_TAG_ALL_CONTACTS;
    cachedActiveCellTag = CELL_TAG_ALL_CONTACTS;
    unwantedCharsSet = [[NSCharacterSet characterSetWithCharactersInString:ALLOWED_CHARS] invertedSet];
    self.sendingIndicatorView.hidden = YES;
    self.seperatorView.backgroundColor = [UIColor cellSeperatorGray];
    [self initRecordingView];
    activeSendingCount = 0;
    isScrolling  = NO;
    [self initHoldToRecordInfoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.contactsModel = nil;
    self.recentContactsModel = nil;
    self.searchMenu = nil;
    self.fastRecordingView = nil;
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
    if(self.recentContactsModel.contactList.count == 0)
       [self.searchContactsTextField becomeFirstResponder];
}

-(void) initRecordingView {
    self.fastRecordingView = [FastRecordingView createInstanceWithDelegate:self];
    self.fastRecordingView.frame = self.view.frame;
    [self.view addSubview:self.fastRecordingView];
    [self.view bringSubviewToFront:self.fastRecordingView];
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
        activeContactList = self.contactsModel.emailContactList;
    } else if (activeCellTag == CELL_TAG_SMS_CONTACTS) {
        activeContactList = self.contactsModel.smsContactList;
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
        cell.delegate = self;
        PeppermintContact *peppermintContact = [[self activeContactList] objectAtIndex:indexPath.row];
        if(peppermintContact.avatarImage) {
            cell.avatarImageView.image = peppermintContact.avatarImage;
        } else {
            cell.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
        }        
        cell.contactNameLabel.text = peppermintContact.nameSurname;        
        NSString *filteredCommunicationChannelAddress = [[peppermintContact.communicationChannelAddress componentsSeparatedByCharactersInSet:unwantedCharsSet] componentsJoinedByString:@""];
        cell.contactViaInformationLabel.text = filteredCommunicationChannelAddress;
        preparedCell = cell;
    } else {
        NSLog(@"Queried for indexpath: %d,%d and the active contact list has %d elemends", indexPath.section, indexPath.row, [self activeContactList].count);
        return [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath];
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

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isScrolling = YES;
    [self hideHoldToRecordInfoView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    isScrolling = NO;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.searchContactsTextField resignFirstResponder];
    isScrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isScrolling = NO;
}

/*
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self activeContactList].count > indexPath.row) {
        PeppermintContact *selectedContact = [[self activeContactList] objectAtIndex:indexPath.row];
        [self.searchContactsTextField resignFirstResponder];
        if([self shouldPerformSegueWithIdentifier:SEGUE_RECORDING_VIEW_CONTROLLER sender:selectedContact]) {
            [self performSegueWithIdentifier:SEGUE_RECORDING_VIEW_CONTROLLER sender:selectedContact];
        }
    }
}
*/

#pragma mark - HoldToRecordInfoView

-(void) initHoldToRecordInfoView {
    self.holdToRecordInfoView.hidden = YES;
    self.holdToRecordInfoViewLabel.font = [UIFont openSansSemiBoldFontOfSize:14];
    self.holdToRecordInfoViewLabel.text = LOC(@"Hold to record message",@"Hold to record message");
    UITapGestureRecognizer *tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHoldToRecordInfoView)];
    [self.holdToRecordInfoView addGestureRecognizer:tapRecogniser];
}

-(void) hideHoldToRecordInfoView {
    [UIView animateWithDuration:ANIM_TIME animations:^{
        self.holdToRecordInfoView.alpha = 0;
    } completion:^(BOOL finished) {
        self.holdToRecordInfoView.hidden = YES;
    }];
}

#pragma mark - ContactTableViewCellDelegate

-(void) didShortTouchOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    if(!isScrolling) {
        self.holdToRecordInfoView.hidden = YES;
        CGFloat cellHeight = CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
        location.y +=  cellHeight * (3/4);
        if(location.y + self.holdToRecordInfoView.frame.size.height <= self.view.frame.size.height) {
            self.holdToRecordInfoViewYValueConstraint.constant = location.y;
            [self.view layoutIfNeeded];
            self.holdToRecordInfoView.alpha = 0;
            self.holdToRecordInfoView.hidden = NO;
            [UIView animateWithDuration:ANIM_TIME animations:^{
                self.holdToRecordInfoView.alpha = 1;
            } completion:^(BOOL finished) {
                dispatch_time_t hideTime = dispatch_time(DISPATCH_TIME_NOW, WARN_TIME * NSEC_PER_SEC);
                dispatch_after(hideTime, dispatch_get_main_queue(), ^(void){
                    [self hideHoldToRecordInfoView];
                });
            }];
        } else {
            NSLog(@"Can not show holdToRecordView out of the view");
        }
    }
}

-(void) didBeginItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    self.tableView.bounces = NO;
    
    PeppermintContact *selectedContact = [[self activeContactList] objectAtIndex:indexPath.row];
    [self.searchContactsTextField resignFirstResponder];
    
    if(selectedContact.communicationChannel == CommunicationChannelEmail) {
        SendVoiceMessageModel *sendVoiceMessageModel = [SendVoiceMessageMandrillModel new];
        sendVoiceMessageModel.selectedPeppermintContact = selectedContact;
        self.fastRecordingView.sendVoiceMessageModel = sendVoiceMessageModel;
        [self.fastRecordingView presentWithAnimation];
    } else if (selectedContact.communicationChannel == CommunicationChannelSMS) {
        NSLog(@"SMS functionality is not implemented yet");
    }
}

-(void) didCancelItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    self.tableView.bounces = YES;
    [self.fastRecordingView finishRecordingWithSendMessage:NO];
}

-(void) didFinishItemSelectionOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    self.tableView.bounces = YES;
    [self.fastRecordingView.recordingModel stop];
    BOOL isRecordLengthLong = self.fastRecordingView.totalSeconds >= MAX_RECORD_TIME;
    if(!isRecordLengthLong) {
        BOOL isRecordLengthShort = self.fastRecordingView.totalSeconds <= MIN_VOICE_MESSAGE_LENGTH;
        if(isRecordLengthShort) {
            [self showAlertToRecordMoreThanMinimumMessageLength];
        } else {
            [self showAlertToCompleteLoginInformation];
        }
    }
    
#warning "Remove the above else case and add below code"
    /*
    else if(!self.fastRecordingView.sendVoiceMessageModel.peppermintMessageSender.isValid) {
        [self showAlertToCompleteLoginInformation];
    } else {
        [self.fastRecordingView finishRecordingWithSendMessage:YES];
    }*/
}

#pragma mark - FastRecordingViewDelegate

-(void) messageIsSending {
    [self messageSendingIndicatorSetMessageIsSending];
}

-(void) messageSentWithSuccess {
    [self messageSendingIndicatorSetMessageIsSent];
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
    } else {
        [textField resignFirstResponder];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:settingsButtonTitle, nil];
    [alertView show];
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
    reMenuItem.tag = cellTag;
    return reMenuItem;
}

-(void) initSearchMenu {
    REMenuItem *allContactsMenuItem = [self createMenuItemWithTitle:LOC(@"All Contacts", @"Title")
                                                               icon:@"icon_all"
                                                    iconHighlighted:@"icon_all_touch"
                                                                cellTag:CELL_TAG_ALL_CONTACTS];
    
    REMenuItem *recentContactsMenuItem = [self createMenuItemWithTitle:LOC(@"Recent Contacts", @"Title")
                                                                 icon:@"icon_recent"
                                                      iconHighlighted:@"icon_recent_touch"
                                                                  cellTag:CELL_TAG_RECENT_CONTACTS];
    
    REMenuItem *emailContactsMenuItem = [self createMenuItemWithTitle:LOC(@"Email Contacts", @"Title")
                                                               icon:@"icon_mail"
                                                    iconHighlighted:@"icon_mail_touch"
                                                                cellTag:CELL_TAG_EMAIL_CONTACTS];
    
    REMenuItem *smsContactsMenuItem = [self createMenuItemWithTitle:LOC(@"Phone Contacts", @"Title")
                                                                 icon:@"icon_phone"
                                                      iconHighlighted:@"icon_phone_touch"
                                                                  cellTag:CELL_TAG_SMS_CONTACTS];
    
    allContactsMenuItem.font    = [UIFont openSansSemiBoldFontOfSize:allContactsMenuItem.font.pointSize];
    recentContactsMenuItem.font = [UIFont openSansSemiBoldFontOfSize:recentContactsMenuItem.font.pointSize];
    emailContactsMenuItem.font    = [UIFont openSansSemiBoldFontOfSize:emailContactsMenuItem.font.pointSize];
    smsContactsMenuItem.font    = [UIFont openSansSemiBoldFontOfSize:smsContactsMenuItem.font.pointSize];
    
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

    NSPredicate *itemWithTagPredicate = [NSPredicate predicateWithFormat:@"self.tag == %d", cellTag];
    NSArray *filteredArray = [self.searchMenu.items filteredArrayUsingPredicate:itemWithTagPredicate];
    REMenuItem *activeMenuItem = filteredArray.count > 0 ? [filteredArray objectAtIndex:0] : nil;
    SearchMenuTableViewCell *activeMenuTableViewCell = (SearchMenuTableViewCell*)activeMenuItem.customView;
    self.searchSourceIconImageView.image = [UIImage imageNamed:activeMenuTableViewCell.iconImageName];
    
    
    if(cellTag == CELL_TAG_RECENT_CONTACTS) {
        [self.recentContactsModel refreshRecentContactList];
    } else {
        [self.contactsModel refreshContactList];
    }
}

#pragma mark - MessageSending status indicators

-(void) messageSendingIndicatorSetMessageIsSending {
    self.sendingImageHeightConstraint.constant = SENDING_ICON_HEIGHT;
    [self.sendingImageView layoutIfNeeded];
    self.sendingImageView.image = [UIImage imageNamed:@"icon_message_sending"];
    ++activeSendingCount;
    if(self.sendingIndicatorView.hidden) {
        self.sendingIndicatorView.alpha = 0;
        self.sendingIndicatorView.hidden = NO;
        [UIView animateWithDuration:0.15 animations:^{
            self.sendingIndicatorView.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void) messageSendingIndicatorSetMessageIsSent {
    self.sendingImageHeightConstraint.constant = SENT_ICON_HEIGHT;
    [self.sendingImageView layoutIfNeeded];
    self.sendingImageView.image = [UIImage imageNamed:@"icon_message_sent"];
    [self performSelector:@selector(refreshTheScreen) withObject:nil afterDelay:MESSAGE_SENDING_DURATION];
    --activeSendingCount;
}

-(void) refreshTheScreen {
    if(activeSendingCount == 0) {
        self.sendingIndicatorView.alpha = 1;
        [UIView animateWithDuration:0.15 animations:^{
            self.sendingIndicatorView.alpha = 0;
        } completion:^(BOOL finished) {
            self.sendingIndicatorView.hidden = YES;
            self.sendingIndicatorView.alpha = 1;
        }];
        [self.recentContactsModel refreshRecentContactList];
    }
}

#pragma mark - UIAlertViewDelegate

-(void) showAlertToRecordMoreThanMinimumMessageLength {
    MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelFont = [UIFont openSansFontOfSize:12];
    hud.detailsLabelText = [NSString stringWithFormat:LOC(@"Record More Than Limit Format", @"Format of minimum recording warning text"),
     MIN_VOICE_MESSAGE_LENGTH];
    hud.removeFromSuperViewOnHide = YES;
    hud.yOffset += (self.view.frame.size.height * 0.3);
    
    [hud hide:YES afterDelay:WARN_TIME];
    dispatch_time_t hideTime = dispatch_time(DISPATCH_TIME_NOW, WARN_TIME * 1.2 * NSEC_PER_SEC);
    dispatch_after(hideTime, dispatch_get_main_queue(), ^(void){
        [self.fastRecordingView finishRecordingWithSendMessage:NO];
    });
}

-(void) showAlertToCompleteLoginInformation {
    [self.searchContactsTextField resignFirstResponder];
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Account details message", @"Account details message") ;
    NSString *cancelButtonTitle = LOC(@"Cancel", @"Cancel Message");
    NSString *okButtonTitle = LOC(@"Ok", @"Ok Message");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle, nil];
    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    UITextField *nameSurnameTextField = [alertView textFieldAtIndex:0];
    nameSurnameTextField.secureTextEntry = NO;
    nameSurnameTextField.placeholder = LOC(@"Name surname", @"Name surname");
    nameSurnameTextField.keyboardType = UIKeyboardTypeAlphabet;
    nameSurnameTextField.text = self.fastRecordingView.sendVoiceMessageModel.peppermintMessageSender.nameSurname;
    UITextField *emailTextField = [alertView textFieldAtIndex:1];
    emailTextField.secureTextEntry = NO;
    emailTextField.placeholder = LOC(@"Email", @"Email");
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    emailTextField.text = self.fastRecordingView.sendVoiceMessageModel.peppermintMessageSender.email;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView.message isEqualToString:LOC(@"Contacts access rights explanation", @"Directives to give access rights")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self redirectToSettingsPageForPermission];
                break;
            default:
                break;
        }
    } else if ([alertView.message isEqualToString:LOC(@"Account details message", @"Account details message")]) {
        UITextField *nameSurnameTextField = [alertView textFieldAtIndex:0];
        UITextField *emailTextField = [alertView textFieldAtIndex:1];
        PeppermintMessageSender *peppermintMessageSender = self.fastRecordingView.sendVoiceMessageModel.peppermintMessageSender;
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_OTHER_1:
                peppermintMessageSender.nameSurname = nameSurnameTextField.text;
                peppermintMessageSender.email = emailTextField.text;
                
                if(!peppermintMessageSender.isValid) {
                    [self showAlertToCompleteLoginInformation];
                } else {
                    [peppermintMessageSender save];
                    [self.fastRecordingView finishRecordingWithSendMessage:YES];
                }
                break;
            default:
                [self.fastRecordingView finishRecordingWithSendMessage:NO];
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
            SendVoiceMessageModel *sendVoiceMessageModel = [SendVoiceMessageMandrillModel new];
            sendVoiceMessageModel.selectedPeppermintContact = selectedContact;
            sendVoiceMessageModel.delegate = rvc;
            rvc.sendVoiceMessageModel = sendVoiceMessageModel;
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
            //IF there is a possible limitation implement here...
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
