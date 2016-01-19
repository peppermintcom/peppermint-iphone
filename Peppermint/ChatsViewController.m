//
//  ChatsViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatsViewController.h"

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
    cell.rightMessageCounterLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 6];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected %d-%d", indexPath.section, indexPath.row);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
