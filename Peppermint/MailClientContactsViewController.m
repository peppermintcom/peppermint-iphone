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

@interface MailClientContactsViewController ()
@end

@implementation MailClientContactsViewController

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:[NSBundle mainBundle]];
    MailClientContactsViewController *mailClientContactsViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_MAILCLIENT_CONTACTS];
    return mailClientContactsViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self recentContactsModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _recentContactsModel = nil;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.recentContactsModel refreshRecentContactList];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark - Lazy Loading

-(RecentContactsModel*) recentContactsModel {
    if(_recentContactsModel == nil) {
        _recentContactsModel = [RecentContactsModel new];
        _recentContactsModel.delegate = self;
    }
    return _recentContactsModel;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recentContactsModel.mailClientMessageRecentContactsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
    if (indexPath.row < self.recentContactsModel.mailClientMessageRecentContactsArray.count) {
        PeppermintContact *peppermintContact = [self.recentContactsModel.mailClientMessageRecentContactsArray objectAtIndex:indexPath.row];
        
        [cell setAvatarImage:peppermintContact.avatarImage ? peppermintContact.avatarImage : nil];
        if(peppermintContact.hasReceivedMessageOverPeppermint) {
            peppermintContact.explanation = @"Mail connection";
        }
        [cell setInformationWithNameSurname:peppermintContact.nameSurname communicationChannelAddress:peppermintContact.explanation];
    }
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
}

#pragma mark - RecentContactsModelDelegate

-(void) recentPeppermintContactsRefreshed {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.tableView reloadData];
}

-(void) recentPeppermintContactsSavedSucessfully:(NSArray<PeppermintContact*>*) recentContactsArray {
    NSLog(@"recentPeppermintContactsSavedSucessfully");
}

#pragma mark - ContactTableViewCellDelegate

-(void) didShortTouchOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    if(indexPath.row < self.recentContactsModel.mailClientMessageRecentContactsArray.count) {
        PeppermintContact *peppermintContact = [self.recentContactsModel.mailClientMessageRecentContactsArray objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:SEGUE_CHAT_ENTRIES_VIEWCONTROLLER sender:peppermintContact];
    }
}

-(void) didBeginItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    NSLog(@"didBeginItemSelectionOnIndexpath");
}

-(void) didCancelItemSelectionOnIndexpath:(NSIndexPath*) indexPath location:(CGPoint) location {
    NSLog(@"didCancelItemSelectionOnIndexpath");
}

-(void) didFinishItemSelectionOnIndexPath:(NSIndexPath*) indexPath location:(CGPoint) location {
    NSLog(@"didFinishItemSelectionOnIndexPath");
}

-(void) didFinishItemSelectionWithSwipeActionOccuredOnLocation:(NSIndexPath*) indexPath location:(CGPoint) location {
    NSLog(@"didFinishItemSelectionWithSwipeActionOccuredOnLocation");
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
