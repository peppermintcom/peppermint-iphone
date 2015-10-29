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

#define SEGUE_RECORDING_VIEW_CONTROLLER         @"RecordingViewControllerSegue"

#define CELL_TAG_ALL_CONTACTS       1
#define CELL_TAG_RECENT_CONTACTS    2
#define CELL_TAG_EMAIL_CONTACTS     3
#define CELL_TAG_SMS_CONTACTS       4

#define ALLOWED_CHARS @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@."
#define MESSAGE_SENDING_DURATION   2

@interface ContactsViewController ()

@end

@implementation ContactsViewController {
    NSUInteger activeCellTag;
    NSUInteger cachedActiveCellTag;
    NSCharacterSet *unwantedCharsSet;
    BOOL callLockForCurrentMessage;
    NSUInteger activeSendingCount;
    BOOL isScrolling;
    MBProgressHUD *_loadingHud;
    AWSModel *awsModel;
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
    activeCellTag = CELL_TAG_ALL_CONTACTS;
    cachedActiveCellTag = CELL_TAG_ALL_CONTACTS;
    unwantedCharsSet = [[NSCharacterSet characterSetWithCharactersInString:ALLOWED_CHARS] invertedSet];
    self.sendingIndicatorView.hidden = YES;
    self.seperatorView.backgroundColor = [UIColor cellSeperatorGray];
    [self initRecordingView];
    callLockForCurrentMessage = NO;
    activeSendingCount = 0;
    isScrolling  = NO;
    [self initHoldToRecordInfoView];
}

-(void) recorderInitIsSuccessful {
    NSLog(@"recorder is inited");    
    UIImage *image = [UIImage imageNamed:@"recording_logo_pressed"];
    NSData *data = UIImagePNGRepresentation(image);
    [awsModel startToUploadData:data ofType:@"image/png"];
}

-(void) fileUploadCompletedWithPublicUrl:(NSString*) url {
    NSLog(@"Url is %@", url);
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
    [[self loadingHud] show:YES];
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
    [self.reSideMenuContainerViewController presentLeftMenuViewController];
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
        ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        PeppermintContact *peppermintContact = [[self activeContactList] objectAtIndex:indexPath.row];
        if(peppermintContact.avatarImage) {
            cell.avatarImageView.image = peppermintContact.avatarImage;
        } else {
            cell.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
        }        
        cell.contactNameLabel.text = peppermintContact.nameSurname;        
        NSString *filteredCommunicationChannelAddress = [[peppermintContact.communicationChannelAddress componentsSeparatedByCharactersInSet:unwantedCharsSet] componentsJoinedByString:@""];
        cell.contactViaInformationLabel.text = filteredCommunicationChannelAddress;
                
        NSPredicate *predicate = [self.recentContactsModel recentContactPredicate:peppermintContact];
        NSArray *filteredArray = [self.recentContactsModel.contactList filteredArrayUsingPredicate:predicate];
        
        if(filteredArray.count > 0) {
            cell.rightIconImageView.image = [UIImage imageNamed:@"icon_recent"];
        } else if(peppermintContact.communicationChannel == CommunicationChannelEmail) {
            cell.rightIconImageView.image = [UIImage imageNamed:@"icon_mail"];
        } else if (peppermintContact.communicationChannel == CommunicationChannelSMS) {
            cell.rightIconImageView.image = [UIImage imageNamed:@"icon_phone"];
        }
        
        preparedCell = cell;
    } else {
        return [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:nil];
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

#pragma mark - LoadingView
-(MBProgressHUD*) loadingHud {
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

        _loadingHud.minShowTime = 1;
        _loadingHud.graceTime = 0.2;
        _loadingHud.color = [UIColor clearColor];
        _loadingHud.margin = 0;
        _loadingHud.mode = MBProgressHUDModeCustomView;
        _loadingHud.customView = customView;
    }
    return _loadingHud;
}

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
    
    SendVoiceMessageModel *sendVoiceMessageModel = nil;
    if(selectedContact.communicationChannel == CommunicationChannelEmail) {
        sendVoiceMessageModel = [SendVoiceMessageMandrillModel new];
    } else if (selectedContact.communicationChannel == CommunicationChannelSMS) {
        sendVoiceMessageModel = [SendVoiceMessageSMSModel new];
    }
    
    if([sendVoiceMessageModel isServiceAvailable]) {
        sendVoiceMessageModel.selectedPeppermintContact = selectedContact;
        self.fastRecordingView.sendVoiceMessageModel = sendVoiceMessageModel;
        self.reSideMenuContainerViewController.panGestureEnabled = NO;
        [self.fastRecordingView presentWithAnimation];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelFont = [UIFont openSansSemiBoldFontOfSize:13];
        hud.detailsLabelText = LOC(@"Service is not available", @"Service is not available message");
        CGFloat messageShiftValue = 50;
        CGFloat center = self.view.frame.size.height / 2 - messageShiftValue;
        hud.yOffset = location.y - center;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:WARN_TIME/2];
    }
}

-(void) didCancelItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    self.tableView.bounces = YES;
    [self.fastRecordingView finishRecordingWithGestureIsValid:NO];
}

-(void) didFinishItemSelectionOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    self.tableView.bounces = YES;
    [self.fastRecordingView finishRecordingWithGestureIsValid:YES];
}

#pragma mark - FastRecordingViewDelegate

-(void) fastRecordingViewDissappeared {
    self.reSideMenuContainerViewController.panGestureEnabled = YES;
}

-(void) messageStatusIsUpdated:(SendingStatus)sendingStatus withCancelOption:(BOOL)cancelable {
    self.cancelMessageSendingButton.hidden = !cancelable;
    NSMutableAttributedString *infoAttrText = [NSMutableAttributedString new];
    UIColor *textColor = [UIColor textFieldTintGreen];
    
    if(sendingStatus == SendingStatusUploading) {
        infoAttrText = [self addText:LOC(@"Uploading", @"Info") ofSize:13 ofColor:textColor toAttributedText:infoAttrText];
        [self messageSendingIndicatorSetMessageIsSending];
    } else if (sendingStatus == SendingStatusStarting) {
        infoAttrText = [self addText:LOC(@"Starting", @"Info") ofSize:13 ofColor:textColor toAttributedText:infoAttrText];
        [self messageSendingIndicatorSetMessageIsSending];
    } else if (sendingStatus == SendingStatusSending) {
        infoAttrText = [self addText:LOC(@"Sending", @"Info") ofSize:13 ofColor:textColor toAttributedText:infoAttrText];
        [self messageSendingIndicatorSetMessageIsSending];
    }  else if (sendingStatus == SendingStatusSent) {
        cancelable = NO;
        infoAttrText = [self addTick:infoAttrText ofSize:21];
        infoAttrText = [self addText:LOC(@"Sent", @"Info") ofSize:21 ofColor:textColor toAttributedText:infoAttrText];
        [self messageSendingIndicatorSetMessageIsSent];
    }  else if (sendingStatus == SendingStatusCancelled) {
        infoAttrText = [self addText:LOC(@"Cancelled", @"Info") ofSize:19 ofColor:textColor toAttributedText:infoAttrText];
        [self messageCancelButtonPressed:nil];
    }
    if(cancelable) {
        infoAttrText = [self addText:LOC(@"Tap to cancel", @"Info") ofSize:13
                             ofColor:[UIColor peppermintCancelOrange] toAttributedText:infoAttrText];
    }
    self.sendingInformationLabel.attributedText = [self centerText:infoAttrText];
}

-(NSMutableAttributedString*) centerText:(NSMutableAttributedString*) attrText {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attrText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrText length])];
    return attrText;
}

-(NSMutableAttributedString*) addTick:(NSMutableAttributedString*) attrText ofSize:(NSInteger) size {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"icon_tick"];
    attachment.bounds = CGRectMake(0, 0, size, size);
    NSAttributedString *tickAttachment = [NSAttributedString attributedStringWithAttachment:attachment];
    [attrText appendAttributedString:tickAttachment];
    return attrText;
}

-(NSMutableAttributedString*) addText:(NSString*)text ofSize:(NSUInteger)size ofColor:(UIColor*)color toAttributedText:(NSMutableAttributedString*) attrMutableText {
    JPStringAttribute *infoAttr = [JPStringAttribute new];
    infoAttr.foregroundColor = color;
    infoAttr.font = [UIFont openSansBoldFontOfSize:size];
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text
                                                                   attributes:infoAttr.attributedDictionary];
    [attrMutableText appendAttributedString:attrText];
    return attrMutableText;
}

#pragma mark - MessageSending status indicators

-(void) messageSendingIndicatorSetMessageIsSending {
    if(!callLockForCurrentMessage) {
        callLockForCurrentMessage  = YES;
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
}

-(void) messageSendingIndicatorSetMessageIsSent {
    [self performSelector:@selector(refreshTheScreen) withObject:nil afterDelay:MESSAGE_SENDING_DURATION];
    callLockForCurrentMessage = NO;
    --activeSendingCount;
}

-(void) messageSendingIsCancelled {
    callLockForCurrentMessage = NO;
    --activeSendingCount;
    [self refreshTheScreen];
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

#pragma mark - CancelMessageSendingButton

-(IBAction)messageCancelButtonPressed:(id)sender {
    [self.fastRecordingView cancelMessageSending];
    [self messageSendingIsCancelled];
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(![string isEqual:@"\n"]) {
        [self.searchMenu close];
        self.contactsModel.filterText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = self.contactsModel.filterText;
        [self refreshContacts];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
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
    textField.text = @"";
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
    [[self loadingHud] hide:YES];
    [self.tableView reloadData];
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactSavedSucessfully:(PeppermintContact*) recentContact {
    NSLog(@"Contact saved successfully. %@", recentContact.nameSurname);
}

-(void) recentPeppermintContactsRefreshed {
    if(self.recentContactsModel.contactList.count == 0) {
        [self cellSelectedWithTag:CELL_TAG_ALL_CONTACTS];
    } else {
        [[self loadingHud] hide:YES];
        [self.tableView reloadData];
    }
}

#pragma mark - SearchButton

-(IBAction)searchButtonPressed:(id)sender {
    if(!self.searchMenu.isOpen) {
        [self hideHoldToRecordInfoView];
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
    
    self.searchMenu.shadowOffset = CGSizeMake(1, 2);
    self.searchMenu.shadowColor = [UIColor peppermintGreen];
    self.searchMenu.shadowOpacity = 1;
    self.searchMenu.shadowRadius = 1;
    
    __weak __typeof__(self) weakSelf = self;
    self.searchMenu.closeCompletionHandler = ^{
        weakSelf.searchMenuView.hidden = YES;
    };
}

#pragma mark - SearchMenuTableViewCellDelegate

-(void)cellSelectedWithTag:(NSUInteger) cellTag {
    [self.searchMenu close];
    [self.searchContactsTextField resignFirstResponder];
    self.searchContactsTextField.text = self.contactsModel.filterText = @"";
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView.message isEqualToString:LOC(@"Contacts access rights explanation", @"Directives to give access rights")]) {
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
