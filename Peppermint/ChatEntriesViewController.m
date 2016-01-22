//
//  ChatEntriesViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ChatEntriesViewController.h"

@interface ChatEntriesViewController ()

@end

@implementation ChatEntriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = CELL_HEIGHT_CHAT_CONTACT_TABLEVIEWCELL;
    
    self.tableView.backgroundColor = [UIColor slideMenuTableViewColor];
    self.bottomInformationLabel.font = [UIFont openSansSemiBoldFontOfSize:18];
    self.bottomInformationLabel.textColor = [UIColor textFieldTintGreen];
    self.bottomInformationLabel.backgroundColor = [UIColor peppermintGray248];
    self.bottomInformationLabel.layer.borderWidth = 1;
    self.bottomInformationLabel.layer.borderColor = [UIColor cellSeperatorGray].CGColor;
    self.bottomInformationLabel.text = LOC(@"Record a Message", @"Record a Message");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSParameterAssert(self.chatEntriesModel);
    self.chatEntriesModel.delegate = self;
    
    if(self.chatEntriesModel.chat.avatarImageData) {
        self.avatarImageView.image = [UIImage imageWithData:self.chatEntriesModel.chat.avatarImageData];
    }
    NSMutableAttributedString *attrText = [NSMutableAttributedString new];
    [attrText addText:self.chatEntriesModel.chat.nameSurname ofSize:17 ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:17]];
    [attrText addText:@"\n" ofSize:12 ofColor:[UIColor clearColor]];
    [attrText addText:self.chatEntriesModel.chat.communicationChannelAddress ofSize:13 ofColor:[UIColor recordingNavigationsubTitleGreen]];
    [attrText centerText];
    self.titleLabel.attributedText = attrText;
    
    [self navigateToLastRow];
}

-(void) navigateToLastRow {
    [self.tableView reloadData];
    NSUInteger lastSection = 0;
    NSUInteger lastRowNumber = [self.tableView numberOfRowsInSection:lastSection] - 1;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.chatEntriesModel = nil;
}

#pragma mark - ChatEntriesModelDelegate

-(void) chatEntriesArrayIsUpdated {
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [self.chatEntriesModel.chatEntriesArray count];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatContactTableViewCell *cell = [CellFactory cellChatContactTableViewCellFromTable:tableView forIndexPath:indexPath];
    
    ChatEntry *chatEntry = (ChatEntry*)[self.chatEntriesModel.chatEntriesArray objectAtIndex:indexPath.row];
    
    NSString *nameSurname = chatEntry.transcription;
    NSString *address = chatEntry.dateCreated.description;
    
    if(nameSurname.length == 0) {
        nameSurname = @"*|*";
    }
    
    if(address.length == 0) {
        address = @"-|-";
    }
    
    [cell setInformationWithNameSurname:nameSurname communicationChannelAddress:address];
    return cell;
}

#pragma mark - Back button

-(IBAction) backButtonTouchDown:(id)sender {
    UIButton *menuButton = (UIButton*)sender;
    menuButton.alpha = 0.7;
}

-(IBAction) backButtonTouchUp:(id)sender {
    UIButton *menuButton = (UIButton*)sender;
    menuButton.alpha = 1;
}

-(IBAction) backButtonValidAction:(id)sender {
    [self backButtonTouchUp:sender];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
