//
//  MailClientContactsViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "MailClientContactsViewController.h"
#import "ChatEntriesViewController.h"

#define SEGUE_CHAT_ENTRIES_VIEWCONTROLLER   @"ChatEntriesViewControllerSegue"

@implementation MailClientContactsViewController {
    NSArray<PeppermintContactWithChatEntry*> *nonFilteredPeppermintContactWithChatEntryArray;
}

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:[NSBundle mainBundle]];
    MailClientContactsViewController *mailClientContactsViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_MAILCLIENT_CONTACTS];
    return mailClientContactsViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchContactsTextField.font = [UIFont openSansFontOfSize:14];
    self.searchContactsTextField.text = @"";
    self.searchContactsTextField.placeholder = LOC(@"Search", @"Search Text");
    self.searchContactsTextField.tintColor = [UIColor textFieldTintGreen];
    self.searchContactsTextField.delegate = self;
    self.searchContactsTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.searchContactsTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self recentContactsModel];
    REGISTER();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _recentContactsModel = nil;
    _chatEntryModel = nil;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.recentContactsModel refreshRecentContactList];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.whiteEllipseView.layer.cornerRadius = self.whiteEllipseView.frame.size.height / 3.4;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Lazy Loading

-(RecentContactsModel*) recentContactsModel {
    if(_recentContactsModel == nil) {
        _recentContactsModel = [RecentContactsModel new];
        _recentContactsModel.delegate = self;
    }
    return _recentContactsModel;
}

-(ChatEntryModel*) chatEntryModel {
    if(_chatEntryModel == nil) {
        _chatEntryModel = [ChatEntryModel new];
        _chatEntryModel.delegate = self;
    }
    return _chatEntryModel;
}

-(NSArray<PeppermintContactWithChatEntry*>*) peppermintContactWithChatEntryArray {
    if(_peppermintContactWithChatEntryArray == nil) {
        NSString *filterText = self.searchContactsTextField.text;
        _peppermintContactWithChatEntryArray = [self.chatEntryModel filter:nonFilteredPeppermintContactWithChatEntryArray withFilter:filterText];
    }
    return _peppermintContactWithChatEntryArray;
}

SUBSCRIBE(RefreshIncomingMessagesCompletedWithSuccess) {
    weakself_create();
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.recentContactsModel refreshRecentContactList];
    });
}

SUBSCRIBE(UserLoggedOut) {
    [self.recentContactsModel refreshRecentContactList];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peppermintContactWithChatEntryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MailContactTableViewCell *cell = [CellFactory cellMailContactTableViewCellFromTable:tableView forIndexPath:indexPath];
    
    if (indexPath.row < self.peppermintContactWithChatEntryArray.count) {
        PeppermintContactWithChatEntry *peppermintContactWithChatEntry = [self.peppermintContactWithChatEntryArray objectAtIndex:indexPath.row];
        PeppermintContact *peppermintContact = peppermintContactWithChatEntry.peppermintContact;
        [cell setAvatarImage:peppermintContact.avatarImage ? peppermintContact.avatarImage : nil];
        
        cell.senderNameLabel.text = peppermintContact.nameSurname;
        
        NSDate *mergedDate = [NSDate maxOfDate1:peppermintContact.lastMailClientContactDate
                                          date2:peppermintContact.lastPeppermintContactDate];        
        cell.mailDateLabel.text = [mergedDate monthDayStringWithTodayYesterday];
        PeppermintChatEntry *peppermintChatEntry = peppermintContactWithChatEntry.peppermintChatEntry;
        
        BOOL isRepliedForwarded = peppermintChatEntry.isRepliedAnswered || peppermintChatEntry.isForwarded;
        cell.replyIconViewWidthConstraint.constant = isRepliedForwarded ? WIDTH_REPLY_ICON : 0;
        cell.replyIconViewRightPaddingConstraint.constant = isRepliedForwarded ? WIDTH_PADDING : 0;
        
        BOOL isNewMessage = !peppermintChatEntry.isSeen;
        cell.alertNewMessageLabelWidthConstraint.constant = isNewMessage ? WIDTH_ALERTNEW_LABEL : 0;
        cell.alertNewMessageLabelRightPaddingConstraint.constant = isNewMessage ? WIDTH_PADDING : 0;
        
        if(peppermintChatEntry.type == ChatEntryTypeEmail) {
            cell.mailSubjectLabel.text = peppermintChatEntry.subject;
            cell.mailContentLabel.text = peppermintChatEntry.mailContent;
        } else {            
            NSInteger minutes = peppermintChatEntry.duration / 60;
            NSInteger seconds = (int)peppermintChatEntry.duration % 60;
            cell.mailSubjectLabel.text = (peppermintChatEntry.isSentByMe) ? LOC(@"Sent Audio Message", @"Subject") : LOC(@"Received Audio Message", @"Subject");
            cell.mailContentLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld", minutes, seconds];
        }
    }
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT_MAILCONTACT_TABLEVIEWCELL;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.peppermintContactWithChatEntryArray.count) {
        PeppermintContactWithChatEntry *peppermintContactWithChatEntry = [self.peppermintContactWithChatEntryArray objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER
                                  sender:peppermintContactWithChatEntry.peppermintContact];
    }
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactsRefreshed {
    [self.chatEntryModel getLastMessagesForPeppermintContacts:self.recentContactsModel.mailClientMessageRecentContactsArray];
}

-(void) recentPeppermintContactsSavedSucessfully:(NSArray<PeppermintContact*>*) recentContactsArray {
    NSLog(@"recentPeppermintContactsSavedSucessfully");
}

#pragma mark - ChatEntryModelDelegate

-(void) peppermintChatEntriesArrayIsUpdated {
    NSLog(@"peppermintChatEntriesArrayIsUpdated");
}

-(void) peppermintChatEntrySavedWithSuccess:(NSArray*) savedPeppermintChatEnryArray {
    NSLog(@"peppermintChatEntrySavedWithSuccess:");
}

-(void) lastMessagesAreUpdated:(NSArray<PeppermintContactWithChatEntry*>*) peppermintContactWithChatEntryArray {
    nonFilteredPeppermintContactWithChatEntryArray = peppermintContactWithChatEntryArray;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self refreshContacts];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidChange :(UITextField *)textField {
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
    self.peppermintContactWithChatEntryArray = nil;
    [self.tableView reloadData];
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

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self refreshContacts];
    return YES;
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.searchContactsTextField resignFirstResponder];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER]) {
        if([sender isKindOfClass:[PeppermintContact class]]) {
            PeppermintContact *peppermintContact = (PeppermintContact*)sender;
            ChatEntriesViewController *chatEntriesViewController = (ChatEntriesViewController*)segue.destinationViewController;
            chatEntriesViewController.peppermintContact = peppermintContact;
            chatEntriesViewController.chatEntryTypesToShow = ChatEntryTypeAudio | ChatEntryTypeEmail;
        } else {
            NSLog(@"sender must be an instance of 'PeppermintContact' to navigate!");
        }
    }
}

@end
