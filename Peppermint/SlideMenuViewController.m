//
//  SlideMenuViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "LoginModel.h"
#import "LoginNavigationViewController.h"

#define NUMBER_OF_OPTIONS   4
#define INDEX_CONTACTS      0
#define INDEX_FEEDBACK      1
#define INDEX_TUTORIAL      2
#define INDEX_ACCOUNT       3
#define INDEX_SETTINGS    4


@interface SlideMenuViewController ()

@end

@implementation SlideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor recordingNavigationsubTitleGreen];
    self.userLabel.textColor = [UIColor whiteColor];
    self.userLabel.font = [UIFont openSansSemiBoldFontOfSize:13];
    
    self.avatarImageView.layer.cornerRadius = 10;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.layer.borderWidth = 3;
    self.tableView.backgroundColor = [UIColor slideMenuTableViewColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender new];
    if(peppermintMessageSender.nameSurname.length > 0) {
        self.userLabel.text = peppermintMessageSender.nameSurname;
    } else {
        self.userLabel.text = @"Peppermint";
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NUMBER_OF_OPTIONS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SlideMenuTableViewCell *cell = [CellFactory cellSlideMenuTableViewCellFromTable:tableView forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case INDEX_CONTACTS:
            cell.titleLabel.text = LOC(@"Contacts",@"Contacts Label");
            cell.iconImageView.image = [UIImage imageNamed:@"icon_all"];
            break;
        case INDEX_SETTINGS:
            cell.titleLabel.text = LOC(@"Settings",@"Settings Label");
            cell.iconImageView.image = [UIImage imageNamed:@"icon_settings"];
            break;
        case INDEX_TUTORIAL:
            cell.titleLabel.text = LOC(@"Tutorial",@"Tutorial Label");
            cell.iconImageView.image = [UIImage imageNamed:@"icon_tutorial"];
            break;
        case INDEX_FEEDBACK:
            cell.titleLabel.text = LOC(@"Feedback",@"Feedback Label");
            cell.iconImageView.image = [UIImage imageNamed:@"icon_feedback"];
            break;
        case INDEX_ACCOUNT:
            cell.titleLabel.text = LOC(@"Account", @"Account Label");
            cell.iconImageView.image = [UIImage imageNamed:@"icon_settings"];
            break;
        default:
            break;
    }
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT_SLIDE_MENU_TABLEVIEWCELL;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected %d", indexPath.row);
    [self.reSideMenuContainerViewController hideMenuViewController];
    if(indexPath.row == INDEX_CONTACTS) {
        UINavigationController *navigationController = (UINavigationController*)self.reSideMenuContainerViewController.contentViewController;
        [navigationController popToRootViewControllerAnimated:YES];
    } else if (indexPath.row == INDEX_FEEDBACK) {
        [self.reSideMenuContainerViewController sendFeedback];
    } else if (indexPath.row == INDEX_SETTINGS) {
        UINavigationController *navigationController = (UINavigationController*)self.reSideMenuContainerViewController.contentViewController;
        [navigationController popToRootViewControllerAnimated:YES];
    } else if (indexPath.row == INDEX_TUTORIAL) {
        [self.reSideMenuContainerViewController.navigationController popToRootViewControllerAnimated:YES];
    } else if (indexPath.row == INDEX_ACCOUNT) {
        [LoginNavigationViewController logUserInWithDelegate:nil];
    }
}

@end