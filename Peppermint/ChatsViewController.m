//
//  ChatsViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatsViewController.h"
#import "ChatEntriesViewController.h"
#import "ContactsViewController.h"
#import "ChatModel.h"

#warning "Clear all code connected with ChatsViewController& delete this class!"

#define SEGUE_CHAT_ENTRIES_VIEWCONTROLLER   @"ChatEntriesViewControllerSegue"

@implementation ChatsViewController {
    NSDateFormatter *dateFormatter;
    RecentContactsModel *_recentContactsModel;
    NSString *peppermintContactEmailToNavigate;
    NSSet* _receivedMessagesEmailSet;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = LOC(@"Chats", @"Title");
    
    self.tableView.rowHeight = CELL_HEIGHT_CHAT_CONTACT_TABLEVIEWCELL;
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMM dd"];
    
    [self initChatsEmptyView];
    REGISTER();
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.chatsEmptyView.hidden = YES;
    [self refreshContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _recentContactsModel = nil;
}

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:[NSBundle mainBundle]];
    ChatsViewController *chatsViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_CHATS];
    return chatsViewController;
}


#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactsRefreshed {
    [self.tableView reloadData];
    self.chatsEmptyView.hidden = (self.recentContactsModel.contactList.count > 0);
    [self checkIfShouldNavigate];
}

-(void) recentPeppermintContactsSavedSucessfully:(NSArray<PeppermintContact*>*) recentContactsArray {
    NSLog(@"recentPeppermintContactsSavedSucessfully...");
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = self.recentContactsModel.contactList.count;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatContactTableViewCell *cell = [CellFactory cellChatContactTableViewCellFromTable:tableView forIndexPath:indexPath];
        
    PeppermintContact *peppermintContact = [self.recentContactsModel.contactList objectAtIndex:indexPath.row];
    if(peppermintContact.avatarImage) {
        [cell setAvatarImage:peppermintContact.avatarImage];
    } else {
        cell.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
    }
    
    NSString *communicationChannelAddressToShow = peppermintContact.communicationChannelAddress;
    if([self.receivedMessagesEmailSet containsObject:communicationChannelAddressToShow]) {
        communicationChannelAddressToShow = LOC(@"Peppermint", @"Peppermint");
    }
    [cell setInformationWithNameSurname:peppermintContact.nameSurname communicationChannelAddress:communicationChannelAddressToShow];
    
    
    NSDate *lastMessageDate = peppermintContact.lastMessageDate;
    cell.rightDateLabel.text = [dateFormatter stringFromDate:lastMessageDate];
    NSUInteger unreadMessageCount = peppermintContact.unreadMessageCount;
    cell.rightMessageCounterLabel.hidden = unreadMessageCount <= 0;
    cell.rightMessageCounterLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)unreadMessageCount];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PeppermintContact *peppermintContact = [self.recentContactsModel.contactList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER sender:peppermintContact];
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
    ContactsViewController *contactsViewController = (ContactsViewController*)[self.navigationController.viewControllers firstObject];
    if(contactsViewController) {
        [contactsViewController.reSideMenuContainerViewController presentLeftMenuViewController];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    if([segue.identifier isEqualToString:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER]) {
        if([sender isKindOfClass:[PeppermintContact class]]) {
            PeppermintContact *peppermintContact = (PeppermintContact*)sender;
            ChatEntriesViewController *chatEntriesViewController = (ChatEntriesViewController*)segue.destinationViewController;
            chatEntriesViewController.peppermintContact = peppermintContact;
        } else {
            NSLog(@"sender must be an instance of 'PeppermintContact' to navigate!");
        }
    }
}

#pragma mark - ChatsEmptyView

-(void) initChatsEmptyView {
    int fontSize = 15;
    self.informationLabel.font = [UIFont openSansSemiBoldFontOfSize:fontSize];
    self.informationLabel.textColor = [UIColor emptyResultTableViewCellHeaderLabelTextcolorGray];
    self.informationLabel.text = LOC(@"You haven't sent any messages yet!", @"title");

    self.goBackAndSendMessageLabel.layer.borderWidth = 2;
    self.goBackAndSendMessageLabel.layer.borderColor = [UIColor progressContainerViewGray].CGColor;
    
    self.goBackAndSendMessageLabel.backgroundColor = [UIColor whiteColor];
    self.goBackAndSendMessageLabel.textColor = [UIColor privacyPolicyGreen];
    self.goBackAndSendMessageLabel.font = [UIFont openSansSemiBoldFontOfSize:fontSize];
    self.goBackAndSendMessageLabel.text = LOC(@"Go back and send a message", @"message");
    
    [self.goBackAndSendMessageLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBackAndSendAMessageLabelPressed)]];
}

-(void) goBackAndSendAMessageLabelPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Refresh

-(void) refreshContent {
    _receivedMessagesEmailSet = nil;
    [self.recentContactsModel refreshRecentContactList];
}

#pragma mark - New Message Received

SUBSCRIBE(RefreshIncomingMessagesCompletedWithSuccess) {
    if(event.peppermintChatEntryNewMesssagesArray.count > 0) {
        [self refreshContent];
    }
}

#pragma mark - Navigate to ChatEntry

-(void) scheduleNavigateToChatEntryWithEmail:(NSString*) email {
    peppermintContactEmailToNavigate = email;
    [self refreshContent];
}

-(void) checkIfShouldNavigate {
    if([peppermintContactEmailToNavigate isValidEmail]) {
        NSPredicate *predicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:peppermintContactEmailToNavigate];
        NSArray *matchingChatsArray = [self.recentContactsModel.contactList filteredArrayUsingPredicate:predicate];
        if(matchingChatsArray.count > 0) {
            PeppermintContact *peppermintContact = matchingChatsArray.firstObject;
            [self performSegueWithIdentifier:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER sender:peppermintContact];
        } else {
            NSLog(@"Could not find matching chat with email: %@", peppermintContactEmailToNavigate);
        }
        peppermintContactEmailToNavigate = nil;
    }
}

#pragma mark - Lazy Loading

-(RecentContactsModel*) recentContactsModel {
    if(_recentContactsModel == nil) {
        _recentContactsModel = [RecentContactsModel new];
        _recentContactsModel.delegate = self;
    }
    return _recentContactsModel;
}

-(NSSet*) receivedMessagesEmailSet {
    if(_receivedMessagesEmailSet == nil) {
        _receivedMessagesEmailSet = [ChatModel receivedMessagesEmailSet];
    }
    return _receivedMessagesEmailSet;
}

@end
