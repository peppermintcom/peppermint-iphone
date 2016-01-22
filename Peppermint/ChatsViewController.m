//
//  ChatsViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatsViewController.h"
#import "ChatEntriesViewController.h"

#define SEGUE_CHAT_ENTRIES_VIEWCONTROLLER   @"ChatEntriesViewControllerSegue"

@implementation ChatsViewController {
    NSDateFormatter *dateFormatter;
    ChatModel *chatModel;
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
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = chatModel.chatArray.count;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatContactTableViewCell *cell = [CellFactory cellChatContactTableViewCellFromTable:tableView forIndexPath:indexPath];
        
    Chat *chat = [chatModel.chatArray objectAtIndex:indexPath.row];
    cell.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
    [cell setInformationWithNameSurname:chat.nameSurname communicationChannelAddress:chat.communicationChannelAddress];
    cell.rightDateLabel.text = [dateFormatter stringFromDate:chat.lastMessageDate];
    
    cell.rightMessageCounterLabel.hidden = chat.unreadMessageCount.intValue <= 0;
    cell.rightMessageCounterLabel.text = chat.unreadMessageCount.stringValue;
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
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    if([segue.identifier isEqualToString:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER]) {
        NSParameterAssert(chatModel.selectedChat);
        ChatEntriesViewController *chatEntriesViewController = (ChatEntriesViewController*)segue.destinationViewController;
        chatEntriesViewController.chatEntriesModel = [[ChatEntriesModel alloc] initWithChat:chatModel.selectedChat];
    }
}

@end
