//
//  ContactsViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsViewController.h"
#import "RecordingViewController.h"
#import "SendVoiceMessageSparkPostModel.h"
#import "SendVoiceMessageSMSModel.h"
#import "SlideMenuViewController.h"
#import "FastReplyModel.h"
#import "AddContactViewController.h"
#import "ChatEntriesViewController.h"

#define SECTION_COUNT                   5
#define SECTION_FAST_REPLY_CONTACT      0
#define SECTION_EMPTY_RESULT            1
#define SECTION_CONTACTS                2
#define SECTION_CELL_INFORMATION        3
#define SECTION_CONTACTS_PERMISSION     4

#define ROW_COUNT_FAST_REPLY            1
#define ROW_COUNT_EMPTY_VIEW            1
#define ROW_COUNT_SHOW_ALL_CONTACTS     1
#define ROW_COUNT_CONTACT_PERMISSION    1

#define MESSAGE_SHOW_DURATION           2

#define SEGUE_CHAT_ENTRIES_VIEWCONTROLLER   @"ChatEntriesViewControllerSegue"

@interface ContactsViewController () <AddContactViewControllerDelegate, AddEmailForSMSContactViewDelegate>

@end

@implementation ContactsViewController {
    __block NSUInteger activeCellTag;
    NSUInteger cachedActiveCellTag;
    BOOL isScrolling;
    MBProgressHUD *_loadingHud;
    BOOL isNewRecordAvailable;
    BOOL isAddNewContactModalisUp;
    BOOL isNavigatedToChatEntries;
    NSTimer *timer;
    BOOL isScreenReady;
    NSUInteger activeRecordingView;
    NSTimer *holdToRecordViewTimer;
    BOOL isContactsPermissionGranted;
    
    BOOL isFirstOpen;
    PeppermintContact *lastRecordedPeppermintContact;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isContactsPermissionGranted = YES;
    self.searchContactsTextField.font = [UIFont openSansFontOfSize:14];
    self.searchContactsTextField.text = self.contactsModel.filterText;
    self.searchContactsTextField.placeholder = LOC(@"Search for Contacts", @"Placeholder text");
    self.searchContactsTextField.tintColor = [UIColor textFieldTintGreen];
    self.searchContactsTextField.delegate = self;
    self.searchContactsTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    isScreenReady = NO;
    isFirstOpen = YES;
    [self recentContactsModel];
    [self contactsModel];
    
    [self resetUserInterfaceWithActiveCellTag:CELL_TAG_RECENT_CONTACTS];
    self.sendingIndicatorView.hidden = YES;
    self.sendingInformationLabel.text = @"";
    self.seperatorView.backgroundColor = [UIColor cellSeperatorGray];
    
    self.tutorialView = nil;
    isScrolling  = NO;
    [self initHoldToRecordInfoView];
    isNewRecordAvailable = YES;
    isAddNewContactModalisUp = NO;
    isNavigatedToChatEntries = NO;
    timer = nil;
    [self.searchContactsTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    lastRecordedPeppermintContact = nil;
    REGISTER();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_contactsModel.contactList removeAllObjects];
    _contactsModel = nil;
    _recentContactsModel = nil;
    [_recordingView removeFromSuperview];
    _recordingView = nil;
    self.tutorialView = nil;
    _addEmailForSMSContactView = nil;
}

SUBSCRIBE(SyncGoogleContactsSuccess) {
    [self hideLoading];
    [self cellSelectedWithTag:activeCellTag];
}

SUBSCRIBE(ReplyContactIsAdded) {
    [self cellSelectedWithTag:activeCellTag];
}

SUBSCRIBE(NewUserLoggedIn) {
    _loadingHud = nil;
    [self resetUserInterfaceWithActiveCellTag:CELL_TAG_ALL_CONTACTS];
}

SUBSCRIBE(UserLoggedOut) {
    [self.recentContactsModel refreshRecentContactList];
    [self resetUserInterfaceWithActiveCellTag:CELL_TAG_ALL_CONTACTS];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self checkIfuserIsLoggedIn]) {
        lastRecordedPeppermintContact = nil;
        [self performTutorialViewProcess];
        [self hideHoldToRecordInfoView];
        if(isAddNewContactModalisUp) {
            isAddNewContactModalisUp = !isAddNewContactModalisUp;
            [self textFieldDidChange:self.searchContactsTextField];
        } else if (isNavigatedToChatEntries) {
            isNavigatedToChatEntries = !isNavigatedToChatEntries;
            [self.recentContactsModel refreshRecentContactList];
            //Add if some more action will need to be taken?
        }
    }
}

-(void) resetUserInterfaceWithActiveCellTag:(int)newCellTag {
    //Clear Content
    isScreenReady = NO;
    activeCellTag = -1;
    [self.tableView reloadData];
    
    self.searchContactsTextField.text = self.contactsModel.filterText = @"";
    //Set new parameters
    cachedActiveCellTag = CELL_TAG_ALL_CONTACTS;
    activeCellTag = newCellTag;
    //Refresh with new parameters
    [[self loadingHud] show:YES];
    [self refreshContacts];
}

-(void) performTutorialViewProcess {
    if(self.tutorialView) {
        [self.tutorialView removeFromSuperview];
        self.tutorialView = nil;
    }
    [self initTutorialView];
    [self registerKeyboardActions];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.whiteEllipseView.layer.cornerRadius = self.whiteEllipseView.frame.size.height / 3.4;
    [self checkToTakeOverSendingMessageEvents];
}

-(void) checkToTakeOverSendingMessageEvents {
    SendVoiceMessageModel *activeSendVoiceMessageModel = [SendVoiceMessageModel activeSendVoiceMessageModel];
    if(activeSendVoiceMessageModel) {
        [self messageModel:activeSendVoiceMessageModel
       isUpdatedWithStatus:activeSendVoiceMessageModel.sendingStatus
                cancelAble:activeSendVoiceMessageModel.isCancelAble];
    }
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

-(IBAction)slideMenuValidAction:(id)sender {
    [self hideHoldToRecordInfoView];
    [super slideMenuValidAction:sender];    
}

#pragma mark - ContactList Logic

- (NSArray*) activeContactList {
    NSArray *activeContactList = nil;
    
    if(activeCellTag == CELL_TAG_RECENT_CONTACTS) {
        activeContactList = self.recentContactsModel.peppermintMessageRecentContactsArray;
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
    return isScreenReady && isContactsPermissionGranted;
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
    } else if (section == SECTION_CONTACTS_PERMISSION) {
        numberOfRows = isContactsPermissionGranted ? 0 : ROW_COUNT_CONTACT_PERMISSION;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *preparedCell = nil;
    
    if(indexPath.section == SECTION_FAST_REPLY_CONTACT) {
        ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        PeppermintContact *contact = [FastReplyModel sharedInstance].peppermintContact;
        [cell setAvatarImage:contact.avatarImage ? contact.avatarImage : nil];
        [cell setInformationWithNameSurname:contact.nameSurname communicationChannelAddress:LOC(@"Peppermint", @"Peppermint") andIconImage:[UIImage imageNamed:@"icon_reply"]];
        preparedCell = cell;
    } else if (indexPath.section == SECTION_EMPTY_RESULT) {
        EmptyResultTableViewCell *cell = [CellFactory cellEmptyResultTableViewCellFromTable:tableView forIndexPath:indexPath];
        [cell setVisibiltyOfExplanationLabels:YES];
        BOOL isOneCycleCompleted = [ChatEntrySyncModel sharedInstance].issentMessagesAreInSyncOfFirstCycle
        || [ChatEntrySyncModel sharedInstance].isReciviedMessagesAreInSyncOfFirstCycle;
        BOOL isUserStillLoggedIn = [[PeppermintMessageSender sharedInstance] isUserStillLoggedIn];
        
        if(!isOneCycleCompleted && isUserStillLoggedIn) {
            [cell showLoading];
            cell.headerLabel.text = @"";
        } else if(activeCellTag == CELL_TAG_RECENT_CONTACTS) {
            [cell hideLoading];
            cell.headerLabel.text = LOC(@"There are no recent contacts", @"Empty cell header text");
        } else {
            [cell hideLoading];
            cell.headerLabel.text = LOC(@"No contacts have been found", @"Empty cell header text");
        }
        preparedCell = cell;
    } else  if (indexPath.section == SECTION_CONTACTS) {
        ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        if (indexPath.row < [self activeContactList].count) {
            PeppermintContact *peppermintContact = [[self activeContactList] objectAtIndex:indexPath.row];
            
            PeppermintContact *recentContact = [self recentContactForPeppermintContact:peppermintContact];
            if(recentContact) {
                peppermintContact = recentContact;
            }
            
            [cell setAvatarImage:peppermintContact.avatarImage ? peppermintContact.avatarImage : nil];
            if(peppermintContact.hasReceivedMessageOverPeppermint) {
                peppermintContact.explanation = LOC(@"Peppermint", @"Peppermint");
            }
            [cell setInformationWithNameSurname:peppermintContact.nameSurname communicationChannelAddress:peppermintContact.explanation];
            [self markReadFieldsIfNecessaryForPeppermintContact:peppermintContact inTableViewCell:cell];
        }
        preparedCell = cell;
    } else if (indexPath.section == SECTION_CELL_INFORMATION) {
        ContactInformationTableViewCell *cell = [CellFactory cellContactInformationTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        [cell setViewForAddNewContact];
        preparedCell = cell;
    } else if (indexPath.section == SECTION_CONTACTS_PERMISSION) {
        ContactInformationTableViewCell *cell = [CellFactory cellContactInformationTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        [cell setViewForShowResultsFromPhoneContacts];
        preparedCell = cell;
    }
    return preparedCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if(indexPath.section == SECTION_FAST_REPLY_CONTACT) {
        height = CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
    } else if (indexPath.section == SECTION_EMPTY_RESULT) {
        height = CELL_HEIGHT_EMPTYRESULT_TABLEVIEWCELL;
    } else if (indexPath.section == SECTION_CONTACTS) {
        if (indexPath.row < [self activeContactList].count) {
            height = CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
            PeppermintContact *fastReplyContact = [FastReplyModel sharedInstance].peppermintContact;
            if(fastReplyContact) {
                PeppermintContact *activeContact = [[self activeContactList] objectAtIndex:indexPath.row];
                if([activeContact equals:fastReplyContact]) {
                    height = 0;
                }
            }
        }
    } else if (indexPath.section == SECTION_CELL_INFORMATION) {
        height = CELL_HEIGHT_CONTACT_INFORMATION_TABLEVIEWCELL;
    } else if (indexPath.section == SECTION_CONTACTS_PERMISSION) {
        height = CELL_HEIGHT_CONTACT_INFORMATION_TABLEVIEWCELL;
    }
    return height;
}

#pragma mark - RecentContact Helper

-(PeppermintContact*) recentContactForPeppermintContact:(PeppermintContact*)peppermintContact {
    NSPredicate *predicate = [self.recentContactsModel recentContactPredicate:peppermintContact];
    NSArray *filteredArray = [self.recentContactsModel.peppermintMessageRecentContactsArray filteredArrayUsingPredicate:predicate];
    return filteredArray.count > 0 ? filteredArray.firstObject : nil;
}

-(void) markReadFieldsIfNecessaryForPeppermintContact:(PeppermintContact*) peppermintContact inTableViewCell:(ContactTableViewCell*)cell {
    PeppermintContact *recentContact = [self recentContactForPeppermintContact:peppermintContact];
    if(recentContact) {
        NSDate *lastMessageDate = recentContact.lastPeppermintContactDate;
        cell.rightDateLabel.text = [lastMessageDate monthDayStringWithTodayYesterday];
        
        NSUInteger unreadAudioMessageCount = recentContact.unreadAudioMessageCount;
        cell.rightMessageCounterLabel.hidden = unreadAudioMessageCount <= 0;
        cell.rightMessageCounterLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)unreadAudioMessageCount];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isScrolling = YES;
    [self hideHoldToRecordInfoView];    
    [self cancelOngoingInteractionsInTableViewCells];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    isScrolling = NO;
    [self cancelOngoingInteractionsInTableViewCells];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.searchContactsTextField resignFirstResponder];
    isScrolling = YES;
    [self cancelOngoingInteractionsInTableViewCells];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isScrolling = NO;
    [self cancelOngoingInteractionsInTableViewCells];
}

-(void) cancelOngoingInteractionsInTableViewCells {
    for(UITableViewCell *cell in self.tableView.visibleCells) {
        if([cell isKindOfClass:[ContactTableViewCell class]]) {
            ContactTableViewCell *contactTableViewCell = (ContactTableViewCell*)cell;
            [contactTableViewCell.recordingGestureButton cancelOngoingInteractions];
        }
    }
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

-(void) showHoldToRecordViewAtLocation:(CGPoint) location {
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
            [self initRecordingModel];   //Init recording model to get permission for microphone!
            holdToRecordViewTimer = [NSTimer scheduledTimerWithTimeInterval:MESSAGE_SHOW_DURATION/2 target:self selector:@selector(hideHoldToRecordInfoView) userInfo:nil repeats:NO];
        }];
    } else {
        NSLog(@"Can not show holdToRecordView out of the view");
    }
}

-(void) initRecordingModel {
    RecordingModel *recordingModel = [RecordingModel new];   //Init recording model to get permission for microphone!
    recordingModel.delegate = self.recordingView;
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
        PeppermintContact *peppermintContact = nil;
        if([self isFastReplyRowVisible] && indexPath.row == 0) {
            peppermintContact = [FastReplyModel sharedInstance].peppermintContact;
        } else {
            peppermintContact = [[self activeContactList] objectAtIndex:indexPath.row];
        }
        
        if(peppermintContact) {
            PeppermintContact *recentContact = [self recentContactForPeppermintContact:peppermintContact];
            if (self.searchContactsTextField.isFirstResponder) {
                [self.searchContactsTextField resignFirstResponder];
            } else if(recentContact) {
                [self performSegueWithIdentifier:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER sender:recentContact];
            } else {
                [self showHoldToRecordViewAtLocation:location];
            }
        }
    }
}

-(CGRect) fixTableScrollPositionForIndexPath:(NSIndexPath*)indexPath {
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
    return cellRect;
}

-(void) didBeginItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    BOOL isActiveContactListStillValid = [self activeContactList].count > indexPath.row;
    if(!isScrolling
       && isActiveContactListStillValid) {
        [self.searchContactsTextField resignFirstResponder];
        CGRect cellRect = [self fixTableScrollPositionForIndexPath:indexPath];
        [self hideHoldToRecordInfoView];
        
        PeppermintContact *selectedContact = [FastReplyModel sharedInstance].peppermintContact;
        if(indexPath.section == SECTION_CONTACTS) {
                selectedContact = [[self activeContactList] objectAtIndex:indexPath.row];
        }
        
        SendVoiceMessageModel *sendVoiceMessageModel = nil;
        if(selectedContact.communicationChannel == CommunicationChannelEmail) {
            sendVoiceMessageModel = [SendVoiceMessageSparkPostModel new];
        } else if (selectedContact.communicationChannel == CommunicationChannelSMS) {
            //sendVoiceMessageModel = [SendVoiceMessageSMSModel new];
            [self.addEmailForSMSContactView presentOverView:self.view forPeppermintContact:selectedContact];
            return;
        }
        
        if(!isNewRecordAvailable) {
            NSLog(@"Please wait for a new record..");
        } else if (sendVoiceMessageModel == nil) {
            NSLog(@"SendVoiceMessageModel could not be defined for this contact..");            
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
        } else if(![RecordingModel checkRecordPermissions]) {
            [self initRecordingModel];
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
    [self.recordingView finishedRecordingWithSystemCancel];
}

-(void) didFinishItemSelectionOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    self.tableView.bounces = YES;
    lastRecordedPeppermintContact = self.recordingView.sendVoiceMessageModel.selectedPeppermintContact;
    [self.recordingView finishRecordingWithGestureIsValid:YES needsPause:NO];
}

-(void) didFinishItemSelectionWithSwipeActionOccuredOnLocation:(NSIndexPath *)indexPath location:(CGPoint)location {
    self.tableView.bounces = YES;
    [self.recordingView finishRecordingWithGestureIsValid:NO needsPause:NO];
}

#pragma mark - ContactInformationTableViewCellDelegate

-(void) contactInformationButtonPressed:(ContactInformationTableViewCell *)cell {
    if(cell.indexPath.section == SECTION_CELL_INFORMATION) {
        isAddNewContactModalisUp = YES;
        [AddContactViewController presentAddContactControllerWithText:self.searchContactsTextField.text withDelegate:self];
    } else if (cell.indexPath.section == SECTION_CONTACTS_PERMISSION) {
        [self redirectToSettingsPageForPermission];
    }
}

#pragma mark - RecordingViewDelegate

-(void) chatHistoryCreatedWithSuccess {
    NSLog(@"chatHistoryCreatedWithSuccess");
}

-(void) recordingViewDissappeared {
    self.reSideMenuContainerViewController.panGestureEnabled = YES;
}

-(void) newRecentContactisSaved {
    self.searchContactsTextField.text = self.contactsModel.filterText = @"";
}

-(void) messageModel:(SendVoiceMessageModel*)messageModel isUpdatedWithStatus:(SendingStatus)sendingStatus cancelAble:(BOOL)isCacnelAble {
    
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
        [infoAttrText addText:@"  " ofSize:13 ofColor:[UIColor peppermintCancelOrange]];
        [infoAttrText addText:LOC(@"Tap to cancel", @"Info") ofSize:13 ofColor:[UIColor peppermintCancelOrange]];
    } else {
        self.cancelMessageSendingButton.hidden = YES;
    }
    self.sendingInformationLabel.attributedText = [infoAttrText centerText];
    [self showMessageWithDuration:durationToHideMessage];
    
    [self checkShouldNavigateWithModel:messageModel];
}

-(void) checkShouldNavigateWithModel:(SendVoiceMessageModel*)sendVoiceMessageModel {
    BOOL isInCorrectState = sendVoiceMessageModel.sendingStatus == SendingStatusSendingWithNoCancelOption;
    BOOL isCacheMessage = (sendVoiceMessageModel.delegate == nil);
    BOOL isScreenActive = self.navigationController.viewControllers.lastObject == self;
    BOOL isForCorrectRecording = lastRecordedPeppermintContact
    && [sendVoiceMessageModel.selectedPeppermintContact isEqual:lastRecordedPeppermintContact];
    BOOL isNotRecording = self.recordingView.isHidden;
    BOOL isKeyboardHidden = self.tableViewBottomConstraint.constant == 0;
    BOOL noUserInterraction = isNotRecording && isKeyboardHidden;
    
    if(isInCorrectState
       && !isCacheMessage
       && isScreenActive
       && isForCorrectRecording
       && noUserInterraction) {
        lastRecordedPeppermintContact = nil;
        [self performSegueWithIdentifier:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER sender:sendVoiceMessageModel.selectedPeppermintContact];
    }
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

-(void) scrollToTop {
    weakself_create();
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView setContentOffset:CGPointZero animated:YES];
    });
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self scrollToTop];
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
    isContactsPermissionGranted = NO;
}

-(void) contactListRefreshed {
    [self hideLoading];
    [self.tableView reloadData];
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactsSavedSucessfully:(NSArray<PeppermintContact*>*) recentContactsArray {
    for(PeppermintContact *recentContact in recentContactsArray) {
        NSLog(@"Contact saved successfully. %@", recentContact.nameSurname);
    }
}

-(void) recentPeppermintContactsRefreshed {
    if([self shouldUpdateActiveCellTag]) {
        [self resetUserInterfaceWithActiveCellTag:CELL_TAG_ALL_CONTACTS];
    } else {
        [self hideLoading];
        [self.tableView reloadData];
    }
}

-(BOOL) shouldUpdateActiveCellTag {
    BOOL isRecentContactsListEmpty = (self.recentContactsModel.peppermintMessageRecentContactsArray.count == 0);
    BOOL isActiveCelTagRecentContacts = (activeCellTag == CELL_TAG_RECENT_CONTACTS);
    BOOL result = isFirstOpen && isRecentContactsListEmpty && isActiveCelTagRecentContacts;
    isFirstOpen = NO;
    return result;
}

#pragma mark - AddEmailForSMSContactViewDelegate

-(void) addEmailIsSuccessfullWithEmailContact:(PeppermintContact*) peppermintContact {
    [self refreshContacts];
}

#pragma mark - SearchMenuTableViewCellDelegate

-(void) cellSelectedWithTag:(NSUInteger) cellTag {
    activeCellTag = cellTag;
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

SUBSCRIBE(RefreshIncomingMessagesCompletedWithSuccess) {
    weakself_create();
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL partialUpdate = ![ChatEntrySyncModel sharedInstance].isAllMessagesAreInSyncOfFirstCycle
        && event.peppermintChatEntryAllMesssagesArray.count > 0;
        BOOL newMessage = [ChatEntrySyncModel sharedInstance].isAllMessagesAreInSyncOfFirstCycle
        && event.peppermintChatEntryNewMesssagesArray.count > 0;
        if(isScreenReady && (partialUpdate || newMessage)) {
            [weakSelf.recentContactsModel refreshRecentContactList];
        }
    });
}

SUBSCRIBE(MessageIsMarkedAsRead) {
    [self.recentContactsModel refreshRecentContactList];
}

#pragma mark - Lazy Loading

-(ContactsModel*) contactsModel {
    if(_contactsModel == nil) {
        _contactsModel = [ContactsModel sharedInstance];
        _contactsModel.delegate = self;
        [_contactsModel setup];
        if(isScreenReady) {
            [_contactsModel refreshContactList];
        }
    }
    return _contactsModel;
}

-(RecentContactsModel*) recentContactsModel {
    if(_recentContactsModel == nil) {
        _recentContactsModel = [RecentContactsModel new];
        _recentContactsModel.delegate = self;
        if(isScreenReady) {
            [_recentContactsModel refreshRecentContactList];
        }
    }
    return _recentContactsModel;
}

-(RecordingView*) recordingView {
    if(_recordingView == nil) {
        [self initRecordingView];
    }
    return _recordingView;
}

-(AddEmailForSMSContactView*) addEmailForSMSContactView {
    if(!_addEmailForSMSContactView) {
        _addEmailForSMSContactView = [AddEmailForSMSContactView createInstanceWithDelegate:self];
    }
    return _addEmailForSMSContactView;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER]) {
        if([sender isKindOfClass:[PeppermintContact class]]) {
            PeppermintContact *peppermintContact = (PeppermintContact*)sender;
            ChatEntriesViewController *chatEntriesViewController = (ChatEntriesViewController*)segue.destinationViewController;
            chatEntriesViewController.peppermintContact = peppermintContact;
            chatEntriesViewController.chatEntryTypesToShow = ChatEntryTypeAudio;
            isNavigatedToChatEntries = YES;
        } else {
            NSLog(@"sender must be an instance of 'PeppermintContact' to navigate!");
        }
    }
}

-(void) scheduleNavigateToChatEntryWithEmail:(NSString *)email {
#warning "What if the searched email is not in active list but it is existing in the DB?"
    if([email isValidEmail]) {
        NSPredicate *predicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:email];
        NSArray *matchingChatsArray = [self.recentContactsModel.peppermintMessageRecentContactsArray filteredArrayUsingPredicate:predicate];
        if(matchingChatsArray.count > 0) {
            PeppermintContact *peppermintContact = matchingChatsArray.firstObject;
            
            [self performSegueWithIdentifier:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER sender:peppermintContact];
        } else {
            NSLog(@"Could not find matching chat with email: %@", email);
        }
    }
}

@end
