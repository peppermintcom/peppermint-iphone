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

@interface ChatsViewController ()

@end

@implementation ChatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = LOC(@"Chats", @"Title");
    
    self.tableView.rowHeight = CELL_HEIGHT_CHAT_CONTACT_TABLEVIEWCELL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:[NSBundle mainBundle]];
    ChatsViewController *chatsViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_CHATS];
    return chatsViewController;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 5;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatContactTableViewCell *cell = [CellFactory cellChatContactTableViewCellFromTable:tableView forIndexPath:indexPath];
    cell.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
    [cell setInformationWithNameSurname:@"Okan Kurtulus" communicationChannelAddress:@"okankurtulus@gmail.com"];
    
    cell.rightDateLabel.text = @"Oct 18";
    
    
    cell.rightMessageCounterLabel.hidden = indexPath.row % 3 == 0;
    cell.rightMessageCounterLabel.text = [NSString stringWithFormat:@"%ld", (indexPath.row + 6)];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected %ld-%ld", indexPath.section, indexPath.row);
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
    NSLog(@"Back button pressed");
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    if([segue.identifier isEqualToString:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER]) {
        ChatEntriesViewController *chatEntriesViewController = (ChatEntriesViewController*)segue.destinationViewController;
        
        
        Chat *chat = [Chat new];
        chat.nameSurname = @"Milica Jelena Pakic";
        chat.communicationChannelAddress = @"okankurtulus@gmail.com";
        
    }
}

@end
