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

#define SEGUE_CHAT_ENTRIES_VIEWCONTROLLER   @"ChatEntriesViewControllerSegue"

@implementation ChatsViewController {
    NSDateFormatter *dateFormatter;
    ChatModel *chatModel;
    PeppermintContact *peppermintContactToNavigate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = LOC(@"Chats", @"Title");
    
    self.tableView.rowHeight = CELL_HEIGHT_CHAT_CONTACT_TABLEVIEWCELL;
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMM dd"];
    
    chatModel = [ChatModel new];
    chatModel.delegate = self;
    [self initChatsEmptyView];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    chatModel.delegate = self;
    self.chatsEmptyView.hidden = YES;
    [chatModel refreshChatArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    chatModel = nil;
}

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:[NSBundle mainBundle]];
    ChatsViewController *chatsViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_CHATS];
    return chatsViewController;
}

#pragma mark - ChatModelDelegate

-(void) chatsArrayIsUpdated {
    [self.tableView reloadData];
    self.chatsEmptyView.hidden = (chatModel.chatArray.count > 0);
    [self checkIfShouldNavigate];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = chatModel.chatArray.count;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatContactTableViewCell *cell = [CellFactory cellChatContactTableViewCellFromTable:tableView forIndexPath:indexPath];
        
    Chat *chat = [chatModel.chatArray objectAtIndex:indexPath.row];
    if(chat.avatarImageData) {
        [cell setAvatarImage:[UIImage imageWithData:chat.avatarImageData]];
    } else {
        cell.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
    }
    
    [cell setInformationWithNameSurname:chat.nameSurname communicationChannelAddress:chat.communicationChannelAddress];
    
    NSDate *lastMessageDate = [ChatModel lastMessageDateOfChat:chat];
    cell.rightDateLabel.text = [dateFormatter stringFromDate:lastMessageDate];
    NSUInteger unreadMessageCount = [ChatModel unreadMessageCountOfChat:chat];
    cell.rightMessageCounterLabel.hidden = unreadMessageCount <= 0;
    cell.rightMessageCounterLabel.text = [NSString stringWithFormat:@"%ld",unreadMessageCount];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    chatModel.selectedChat = [chatModel.chatArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER sender:self];
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
        NSParameterAssert(chatModel.selectedChat);
        ChatEntriesViewController *chatEntriesViewController = (ChatEntriesViewController*)segue.destinationViewController;
        [chatModel resetChatEntries];
        chatEntriesViewController.chatModel = chatModel;
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

#pragma mark - Navigate to ChatEntry

-(void) scheduleNavigateToChatEntryWithEmail:(NSString*) email nameSurname:(NSString*)nameSurname {
    PeppermintContact *peppermintContact = [PeppermintContact new];
    peppermintContact.nameSurname = nameSurname;
    peppermintContact.communicationChannelAddress = email;
    peppermintContact.communicationChannel = CommunicationChannelEmail;
    peppermintContactToNavigate = peppermintContact;
}

-(void) checkIfShouldNavigate {
    if(peppermintContactToNavigate) {
        NSPredicate *predicate = [ContactsModel contactPredicateWithCommunicationChannelAddress:peppermintContactToNavigate.communicationChannelAddress communicationChannel:CommunicationChannelEmail];
        
        NSArray *matchingChatsArray = [chatModel.chatArray filteredArrayUsingPredicate:predicate];
        if(matchingChatsArray.count > 0) {
            chatModel.selectedChat = matchingChatsArray.firstObject;
            [self performSegueWithIdentifier:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER sender:self];
        } else {
            NSLog(@"Could ot find matching chat with %@:%@",
                  peppermintContactToNavigate.communicationChannelAddress,
                  peppermintContactToNavigate.nameSurname);
        }
        peppermintContactToNavigate = nil;
    }
}

#pragma mark - Refresh Content

-(void) refreshContent {
    [chatModel refreshChatArray];
}

@end
