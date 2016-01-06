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
#import "SendVoiceMessageSMSModel.h"
#import "SlideMenuViewController.h"
#import "FastReplyModel.h"
#import "AddContactViewController.h"

#define SECTION_COUNT                   4
#define SECTION_FAST_REPLY_CONTACT      0
#define SECTION_EMPTY_RESULT            1
#define SECTION_CONTACTS                2
#define SECTION_CELL_INFORMATION        3

#define ROW_COUNT_FAST_REPLY            1
#define ROW_COUNT_EMPTY_VIEW            1
#define ROW_COUNT_SHOW_ALL_CONTACTS     1

#define CELL_TAG_ALL_CONTACTS           1
#define CELL_TAG_RECENT_CONTACTS        2
#define CELL_TAG_EMAIL_CONTACTS         3
#define CELL_TAG_SMS_CONTACTS           4

#define MESSAGE_SHOW_DURATION           2

@interface ContactsViewController () <AddContactViewControllerDelegate>

@end

@implementation ContactsViewController {
    NSUInteger activeCellTag;
    NSUInteger cachedActiveCellTag;
    BOOL isScrolling;
    MBProgressHUD *_loadingHud;
    BOOL isNewRecordAvailable;
    BOOL isAddNewContactModalisUp;
    NSTimer *timer;
    BOOL isScreenReady;
    NSUInteger activeRecordingView;
    NSTimer *holdToRecordViewTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.contactsModel) {
        self.contactsModel = [ContactsModel sharedInstance];
        self.contactsModel.delegate = self;
        [self.contactsModel setup];
    } else if (self.contactsModel.contactList.count == 0) {
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
    activeCellTag = CELL_TAG_ALL_CONTACTS;
    cachedActiveCellTag = CELL_TAG_ALL_CONTACTS;
    self.sendingIndicatorView.hidden = YES;
    self.sendingInformationLabel.text = @"";
    self.seperatorView.backgroundColor = [UIColor cellSeperatorGray];
    [self initRecordingView];
    self.tutorialView = nil;
    isScrolling  = NO;
    [self initHoldToRecordInfoView];
    isNewRecordAvailable = YES;
    isAddNewContactModalisUp = NO;
    timer = nil;
    isScreenReady = NO;
    [self.searchContactsTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    REGISTER();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.contactsModel = nil;
    self.recentContactsModel = nil;
    self.searchMenu = nil;
    self.recordingView = nil;
    self.tutorialView = nil;
}

SUBSCRIBE(SyncGoogleContactsSuccess) {
    [self cellSelectedWithTag:activeCellTag];
}

SUBSCRIBE(ReplyContactIsAdded) {
    [self cellSelectedWithTag:activeCellTag];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self checkIfuserIsLoggedIn]) {
        if(!self.tutorialView) {
            [self initTutorialView];
        }
        [self registerKeyboardActions];
        [self hideHoldToRecordInfoView];
        if(isAddNewContactModalisUp) {
            isAddNewContactModalisUp = !isAddNewContactModalisUp;
            [self cellSelectedWithTag:activeCellTag];
        } else {
            self.searchContactsTextField.text = self.contactsModel.filterText = @"";
            activeCellTag = CELL_TAG_RECENT_CONTACTS;
            self.searchSourceIconImageView.image = [UIImage imageNamed:@"icon_recent"];
            [[self loadingHud] show:YES];
            [self.recentContactsModel refreshRecentContactList];
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void) initRecordingView {
    self.recordingView = [FoggyRecordingView createInstanceWithDelegate:self];
    self.recordingView.frame = self.view.frame;
    [self.view addSubview:self.recordingView];
    [self.view bringSubviewToFront:self.recordingView];
}

-(void) initTutorialView {
    self.tutorialView = [TutorialView createInstance];
    self.tutorialView.frame = self.view.frame;
    [self.view addSubview:self.tutorialView];
    [self.view bringSubviewToFront:self.tutorialView];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self deRegisterKeyboardActions];
}

#pragma mark - Slide Menu

-(IBAction)slideMenuTouchDown:(id)sender {
    UIButton *menuButton = (UIButton*)sender;
    menuButton.alpha = 0.7;
}

-(IBAction)slideMenuTouchUp:(id)sender {
    UIButton *menuButton = (UIButton*)sender;
    menuButton.alpha = 1;
}

-(IBAction)slideMenuValidAction:(id)sender {
    [self slideMenuTouchUp:sender];
    if(self.searchMenu.isOpen) {
        [self.searchMenu close];
    } else {
        [self hideHoldToRecordInfoView];
        [self.reSideMenuContainerViewController presentLeftMenuViewController];
    }
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

#pragma mark - FastReply View

-(BOOL) isFastReplyRowVisible {
    return [[FastReplyModel sharedInstance] doesFastReplyContactsContains:self.searchContactsTextField.text];
}

#pragma mark - EmptyResultTableViewCell

-(BOOL) isEmptyResultTableViewCellVisible {
    return ![self isFastReplyRowVisible]
    && [self activeContactList].count == 0
    && isScreenReady;
}

#pragma mark - CellInformationTableViewCell

-(BOOL) isCellInformationTableViewCellVisible {
    return isScreenReady;
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if(section == SECTION_FAST_REPLY_CONTACT) {
        numberOfRows = [self isFastReplyRowVisible] ? ROW_COUNT_FAST_REPLY : 0;
    } else if (section == SECTION_EMPTY_RESULT) {
        numberOfRows = [self isEmptyResultTableViewCellVisible] ? ROW_COUNT_EMPTY_VIEW : 0;
    } else if (section == SECTION_CONTACTS) {
        numberOfRows = [self activeContactList].count;
    } else if (section == SECTION_CELL_INFORMATION) {
        numberOfRows = [self isCellInformationTableViewCellVisible] ? ROW_COUNT_SHOW_ALL_CONTACTS : 0;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *preparedCell = nil;
    
    if(indexPath.section == SECTION_FAST_REPLY_CONTACT) {
        ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        PeppermintContact *contact = [FastReplyModel sharedInstance].peppermintContact;
        cell.avatarImageView.image = contact.avatarImage;
        cell.contactNameLabel.text = contact.nameSurname;
        cell.contactViaInformationLabel.text = contact.communicationChannelAddress;
        cell.rightIconImageView.image = [UIImage imageNamed:@"icon_reply"];
        preparedCell = cell;
    } else if (indexPath.section == SECTION_EMPTY_RESULT) {
        EmptyResultTableViewCell *cell = [CellFactory cellEmptyResultTableViewCellFromTable:tableView forIndexPath:indexPath];
        [cell setVisibiltyOfExplanationLabels:YES];
        preparedCell = cell;
    } else  if (indexPath.section == SECTION_CONTACTS) {
        ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        if (indexPath.row < [self activeContactList].count) {
            PeppermintContact *peppermintContact = [[self activeContactList] objectAtIndex:indexPath.row];
            if(peppermintContact.avatarImage) {
                
                CGRect frame = cell.avatarImageView.frame;
                int width = frame.size.width;
                int height = frame.size.height;
                cell.avatarImageView.image = [peppermintContact.avatarImage resizedImageWithWidth:width height:height];
                
            } else {
                cell.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
            }
            cell.contactNameLabel.text = peppermintContact.nameSurname;
            cell.contactViaInformationLabel.text = peppermintContact.communicationChannelAddress;
            
            cell.rightIconImageView.hidden = YES;
            /*
            NSPredicate *predicate = [self.recentContactsModel recentContactPredicate:peppermintContact];
            NSArray *filteredArray = [self.recentContactsModel.contactList filteredArrayUsingPredicate:predicate];
            
            if(filteredArray.count > 0) {
                cell.rightIconImageView.image = [UIImage imageNamed:@"icon_recent"];
            } else if(peppermintContact.communicationChannel == CommunicationChannelEmail) {
                cell.rightIconImageView.image = [UIImage imageNamed:@"icon_mail"];
            } else if (peppermintContact.communicationChannel == CommunicationChannelSMS) {
                cell.rightIconImageView.image = [UIImage imageNamed:@"icon_phone"];
            }
            */
        }
        preparedCell = cell;
    } else if (indexPath.section == SECTION_CELL_INFORMATION) {
        ContactInformationTableViewCell *cell = [CellFactory cellContactInformationTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        [cell setViewForAddNewContact];
        preparedCell = cell;
    }
    return preparedCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if(indexPath.section == SECTION_FAST_REPLY_CONTACT) {
        height = CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
    } else if (indexPath.section == SECTION_EMPTY_RESULT) {
        BOOL isBigScreen = [UIScreen mainScreen].bounds.size.height > SCREEN_HEIGHT_LIMIT;
        height = isBigScreen ? CELL_HEIGHT_EMPTYRESULT_TABLEVIEWCELL : CELL_HEIGHT_EMPTYRESULT_TABLEVIEWCELL / 4;        
    } else if (indexPath.section == SECTION_CONTACTS) {
        if (indexPath.row < [self activeContactList].count) {
            PeppermintContact *fastReplyContact = [FastReplyModel sharedInstance].peppermintContact;
            PeppermintContact *activeContact = [[self activeContactList] objectAtIndex:indexPath.row];
            if([activeContact isIdenticalForImage:fastReplyContact]) {
                fastReplyContact.avatarImage = activeContact.avatarImage;
            }
            height = [activeContact equals:fastReplyContact] ? 0 : CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
        }
    } else if (indexPath.section == SECTION_CELL_INFORMATION) {
        height = CELL_HEIGHT_CONTACT_INFORMATION_TABLEVIEWCELL;
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

#pragma mark - LoadingView

-(MBProgressHUD*) loadingHud {
    isScreenReady = NO;
    if(!_loadingHud) {
        _loadingHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        UIView *customView = [[UIView alloc] initWithFrame:self.view.frame];
        UIView *backGroundView = [[UIView alloc] initWithFrame:self.view.frame];
        backGroundView.backgroundColor = [UIColor peppermintGreen];
        backGroundView.alpha = 0.6;
        [customView addSubview:backGroundView];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_loading_contacts"]];
        [customView addSubview:imageView];
        CGFloat totalWidth = customView.frame.size.width;
        CGFloat totalHeight = customView.frame.size.height;
        CGFloat width = totalWidth/3;
        CGFloat height = totalHeight/5;
        imageView.frame = CGRectMake((totalWidth-width) / 2, height*1.5 , width, height);
        [customView bringSubviewToFront:imageView];
        
        _loadingHud.graceTime = 0.4;
        _loadingHud.minShowTime = _loadingHud.graceTime  + 0.2;
        _loadingHud.color = [UIColor clearColor];
        _loadingHud.margin = 0;
        _loadingHud.mode = MBProgressHUDModeCustomView;
        _loadingHud.customView = customView;
    }
    return _loadingHud;
}

-(void) hideLoading {
    isScreenReady = YES;
    [_loadingHud hide:YES];
}

#pragma mark - HoldToRecordInfoView

-(void) initHoldToRecordInfoView {
    holdToRecordViewTimer = nil;
    self.holdToRecordInfoView.hidden = YES;
    self.holdToRecordInfoViewLabel.font = [UIFont openSansSemiBoldFontOfSize:14];
    self.holdToRecordInfoViewLabel.text = LOC(@"Hold to record message",@"Hold to record message");
    
    [self.holdToRecordInfoView addGestureRecognizer:
     [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(hideHoldToRecordInfoView)]];
    [self.holdToRecordInfoView addGestureRecognizer:
     [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHoldToRecordInfoView)]];
    [self.holdToRecordInfoView addGestureRecognizer:
     [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideHoldToRecordInfoView)]];
}

-(void) hideHoldToRecordInfoView {
    [holdToRecordViewTimer invalidate];
    holdToRecordViewTimer = nil;
    [UIView animateWithDuration:ANIM_TIME animations:^{
        self.holdToRecordInfoView.alpha = 0;
    } completion:^(BOOL finished) {
        self.holdToRecordInfoView.hidden = YES;
    }];
}

#pragma mark - ContactTableViewCellDelegate

-(void) didShortTouchOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    if(!isScrolling) {
        [holdToRecordViewTimer invalidate];
        self.holdToRecordInfoView.hidden = YES;
        CGFloat cellHeight = CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
        location.y +=  cellHeight * (3/4);
        if(location.y + self.holdToRecordInfoView.frame.size.height
           <= self.view.frame.size.height) {
            self.holdToRecordInfoViewYValueConstraint.constant = location.y;
            [self.view layoutIfNeeded];
            self.holdToRecordInfoView.alpha = 0;
            self.holdToRecordInfoView.hidden = NO;
            [UIView animateWithDuration:ANIM_TIME animations:^{
                self.holdToRecordInfoView.alpha = 1;
            } completion:^(BOOL finished) {
                [RecordingModel new];   //Init recording model to get permission for microphone!
                holdToRecordViewTimer = [NSTimer scheduledTimerWithTimeInterval:MESSAGE_SHOW_DURATION/2 target:self selector:@selector(hideHoldToRecordInfoView) userInfo:nil repeats:NO];
            }];
        } else {
            NSLog(@"Can not show holdToRecordView out of the view");
        }
    }
}

-(void) didBeginItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    if(!isScrolling) {
        [self.searchContactsTextField resignFirstResponder];
        CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
        cellRect = CGRectOffset(cellRect, -self.tableView.contentOffset.x, -self.tableView.contentOffset.y);
        CGPoint scrollPoint = self.tableView.contentOffset;
        
        if (cellRect.origin.y < 0) {
            scrollPoint.y += cellRect.origin.y;
            cellRect.origin.y = 0;
            [self.tableView setContentOffset:scrollPoint animated:YES];
        }
        
        CGRect tableViewFrame = self.tableView.frame;
        CGFloat margin = 1.5 * CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
        CGFloat maxPossibleYOffset = tableViewFrame.size.height - margin;
        if (cellRect.origin.y > maxPossibleYOffset) {
            scrollPoint.y += cellRect.origin.y - maxPossibleYOffset;
            cellRect.origin.y = maxPossibleYOffset;
            [self.tableView setContentOffset:scrollPoint animated:YES];
        }
        
        self.tableView.bounces = NO;
        [self hideHoldToRecordInfoView];
        
        PeppermintContact *selectedContact = [FastReplyModel sharedInstance].peppermintContact;
        if(indexPath.section == SECTION_CONTACTS) {
            selectedContact = [[self activeContactList] objectAtIndex:indexPath.row];
        }
        [self.searchContactsTextField resignFirstResponder];
        
        SendVoiceMessageModel *sendVoiceMessageModel = nil;
        if(selectedContact.communicationChannel == CommunicationChannelEmail) {
            sendVoiceMessageModel = [SendVoiceMessageMandrillModel new];
        } else if (selectedContact.communicationChannel == CommunicationChannelSMS) {
            sendVoiceMessageModel = [SendVoiceMessageSMSModel new];
        }
        
        if(!isNewRecordAvailable) {
            NSLog(@"Please wait for a new record..");
        } else if(![sendVoiceMessageModel isServiceAvailable]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelFont = [UIFont openSansSemiBoldFontOfSize:13];
            hud.detailsLabelText = LOC(@"Service is not available", @"Service is not available message");
            CGFloat messageShiftValue = 50;
            CGFloat center = self.view.frame.size.height / 2 - messageShiftValue;
            hud.yOffset = location.y - center;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:WARN_TIME/2];
        } else {
            sendVoiceMessageModel.selectedPeppermintContact = selectedContact;
            self.recordingView.sendVoiceMessageModel = sendVoiceMessageModel;
            self.reSideMenuContainerViewController.panGestureEnabled = NO;
            
            cellRect.origin.y += self.tableView.frame.origin.y;
            [self.recordingView presentWithAnimationInRect:cellRect onPoint:location];
        }
    }
}

-(void) didCancelItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    self.tableView.bounces = YES;
    [self.recordingView finishRecordingWithGestureIsValid:NO];
}

-(void) didFinishItemSelectionOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    self.tableView.bounces = YES;
    [self.recordingView finishRecordingWithGestureIsValid:YES];
}

#pragma mark - ContactInformationTableViewCellDelegate

-(void) contactInformationButtonPressed {
    isAddNewContactModalisUp = YES;
    [AddContactViewController presentAddContactControllerWithText:self.searchContactsTextField.text withDelegate:self];
}

#pragma mark - RecordingViewDelegate

-(void) recordingViewDissappeared {
    self.reSideMenuContainerViewController.panGestureEnabled = YES;
}

-(void) newRecentContactisSaved {
    self.searchContactsTextField.text = self.contactsModel.filterText = @"";
    [self cellSelectedWithTag:CELL_TAG_RECENT_CONTACTS];
}

-(void) message:(NSString*) messageId isUpdatedWithStatus:(SendingStatus)sendingStatus cancelAble:(BOOL)isCacnelAble {
    
    NSMutableAttributedString *infoAttrText = [NSMutableAttributedString new];
    UIColor *textColor = [UIColor textFieldTintGreen];
    int durationToHideMessage = MESSAGE_SHOW_DURATION * 2;
    
    if(sendingStatus == SendingStatusUploading) {
        isNewRecordAvailable = YES;
        [infoAttrText addText:LOC(@"Uploading", @"Info") ofSize:13 ofColor:textColor];
    } else if (sendingStatus == SendingStatusStarting) {
        isNewRecordAvailable = NO;
        [infoAttrText addText:LOC(@"Starting", @"Info") ofSize:13 ofColor:textColor];
    } else if (sendingStatus == SendingStatusSending) {
        isNewRecordAvailable = YES;
        [infoAttrText addText:LOC(@"Sending", @"Info") ofSize:13 ofColor:textColor];
        [self.recentContactsModel refreshRecentContactList];
    } else if ( sendingStatus == SendingStatusSendingWithNoCancelOption) {
        isNewRecordAvailable = YES;
        [infoAttrText addText:LOC(@"Sending", @"Info") ofSize:15 ofColor:textColor];
    }  else if (sendingStatus == SendingStatusSent) {
        isNewRecordAvailable = YES;
        [infoAttrText addImageNamed:@"icon_tick" ofSize:14];
        [infoAttrText addText:@"  " ofSize:14 ofColor:textColor];
        [infoAttrText addText:LOC(@"Sent", @"Info") ofSize:21 ofColor:textColor];
        durationToHideMessage = MESSAGE_SHOW_DURATION;
    }  else if (sendingStatus == SendingStatusCancelled) {
        isNewRecordAvailable = YES;
        [infoAttrText addText:LOC(@"Cancelled", @"Info") ofSize:13 ofColor:textColor];
        durationToHideMessage = MESSAGE_SHOW_DURATION;
    } else if (sendingStatus == SendingStatusCached) {
        isNewRecordAvailable = YES;
        [infoAttrText addImageNamed:@"icon_warning" ofSize:10];
        [infoAttrText addText:@" " ofSize:13 ofColor:textColor];
        [infoAttrText addText:LOC(@"Your message will be sent later", @"Cached Info") ofSize:10 ofColor:textColor];
        durationToHideMessage = MESSAGE_SHOW_DURATION * 2;
    } else if (sendingStatus == SendingStatusError) {
        isNewRecordAvailable = YES;
        [infoAttrText addImageNamed:@"icon_warning" ofSize:13];
        [infoAttrText addText:@" " ofSize:13 ofColor:textColor];
        [infoAttrText addText:LOC(@"An error occured", @"Info") ofSize:13 ofColor:textColor];
        durationToHideMessage = MESSAGE_SHOW_DURATION;
    }
    
    if(isCacnelAble && infoAttrText.length > 0) {
        self.cancelMessageSendingButton.hidden = NO;
        [infoAttrText addText:LOC(@"Tap to cancel", @"Info") ofSize:13 ofColor:[UIColor peppermintCancelOrange]];
    } else {
        self.cancelMessageSendingButton.hidden = YES;
    }
    self.sendingInformationLabel.attributedText = [infoAttrText centerText];
    [self showMessageWithDuration:durationToHideMessage];
}

#pragma mark - MessageSending status indicators

-(void) showMessageWithDuration:(int) duration {
    BOOL messageExists = self.sendingInformationLabel.attributedText.length > 0;
    if(messageExists) {
        [self showSendingInfo];
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(hideSendingInfo) userInfo:nil repeats:NO];
    } else {
        [self hideSendingInfo];
    }
}

-(void) hideSendingInfo {
    if (!self.sendingIndicatorView.hidden) {
        self.sendingIndicatorView.alpha = 1;
    }
    [UIView animateWithDuration:0.15 animations:^{
        self.sendingIndicatorView.alpha = 0;
    } completion:^(BOOL finished) {
        self.sendingIndicatorView.hidden = YES;
        self.sendingIndicatorView.alpha = 1;
    }];
}

-(void) showSendingInfo {
    if(self.sendingIndicatorView.hidden) {
        self.sendingIndicatorView.alpha = 0;
        self.sendingIndicatorView.hidden = NO;
    }
    [UIView animateWithDuration:0.15 animations:^{
        self.sendingIndicatorView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - CancelMessageSendingButton

-(IBAction)messageCancelButtonPressed:(id)sender {
    [self.recordingView cancelMessageSending];
}

#pragma mark - TextField

-(void)textFieldDidChange :(UITextField *)textField {
    self.contactsModel.filterText = textField.text;
    [self hideHoldToRecordInfoView];
    [self refreshContacts];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL result = NO;
    if(![string isEqual:DONE_STRING]) {
        [self.searchMenu close];
        result = YES;
    } else {
        [textField resignFirstResponder];
    }
    return result;
}

- (void) refreshContacts {
    
    if(self.searchContactsTextField.text.length > 0
       && activeCellTag == CELL_TAG_RECENT_CONTACTS) {
        cachedActiveCellTag = CELL_TAG_RECENT_CONTACTS;
        activeCellTag = CELL_TAG_ALL_CONTACTS;
    } else if (self.searchContactsTextField.text.length == 0
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.searchMenu close];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.contactsModel.filterText = textField.text = @"";
    [self refreshContacts];
    return NO;
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
    [self hideLoading];
    [self.tableView reloadData];
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactSavedSucessfully:(PeppermintContact*) recentContact {
    NSLog(@"Contact saved successfully. %@", recentContact.nameSurname);
}

-(void) recentPeppermintContactsRefreshed {
    [self hideLoading];
    if(self.recentContactsModel.contactList.count == 0) {
        [self cellSelectedWithTag:CELL_TAG_ALL_CONTACTS];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - SearchButton

-(IBAction)searchButtonPressed:(id)sender {
    if(!self.searchMenu.isOpen) {
        [self hideHoldToRecordInfoView];
        self.searchMenuViewContainer.hidden = NO;
        [self.searchContactsTextField resignFirstResponder];
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
    
    self.searchMenu = [[REMenu alloc] initWithItems:@[allContactsMenuItem, recentContactsMenuItem, emailContactsMenuItem, smsContactsMenuItem]];
    
    self.searchMenu.bounce = NO;
    self.searchMenu.cornerRadius = 5;
    self.searchMenu.borderWidth = 0;
    self.searchMenu.separatorHeight = 0;
    self.searchMenu.separatorColor = [UIColor cellSeperatorGray];
    self.searchMenu.closeOnSelection = YES;
    
    self.searchMenu.shadowOffset = CGSizeMake(1, 2);
    self.searchMenu.shadowColor = [UIColor peppermintGreen];
    self.searchMenu.shadowOpacity = 1;
    self.searchMenu.shadowRadius = 1;
    
    [self.searchMenuViewContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonPressed:)]];
    
    
    weakself_create();
    self.searchMenu.closeCompletionHandler = ^{
        weakSelf.searchMenuViewContainer.hidden = YES;
    };
}

#pragma mark - SearchMenuTableViewCellDelegate

-(void)cellSelectedWithTag:(NSUInteger) cellTag {
    [self.searchMenu close];
    [self.searchContactsTextField resignFirstResponder];
    
    activeCellTag = cellTag;

    NSPredicate *itemWithTagPredicate = [NSPredicate predicateWithFormat:@"self.tag == %d", cellTag];
    NSArray *filteredArray = [self.searchMenu.items filteredArrayUsingPredicate:itemWithTagPredicate];
    REMenuItem *activeMenuItem = filteredArray.count > 0 ? [filteredArray objectAtIndex:0] : nil;
    SearchMenuTableViewCell *activeMenuTableViewCell = (SearchMenuTableViewCell*)activeMenuItem.customView;
    self.searchSourceIconImageView.image = [UIImage imageNamed:activeMenuTableViewCell.iconImageName];
    
    [[self loadingHud] show:YES];
    if(cellTag == CELL_TAG_RECENT_CONTACTS) {
        [self.recentContactsModel refreshRecentContactList];
    } else {
        [self.contactsModel refreshContactList];
    }
}

#pragma mark - AddContactViewControllerDelegate

-(void) nameFieldUpdated:(NSString*)name {
    self.searchContactsTextField.text = self.contactsModel.filterText = name;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView.message isEqualToString:LOC(@"Contacts access rights explanation", @"Directives to give access rights")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [self contactsAccessRightsAreNotSupplied];
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self redirectToSettingsPageForPermission];
                break;
            default:
                NSLog(@"Unhandled button....");
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

@end
