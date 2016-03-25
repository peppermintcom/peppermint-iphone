//
//  SlideMenuViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "LoginModel.h"
#import "AccountViewController.h"
#import "ContactsViewController.h"
#import "AboutViewController.h"

#define INDEX_TUTORIAL      -1

#define NUMBER_OF_OPTIONS   5
#define INDEX_RECENT_CONTACTS      0
#define INDEX_ALL_CONTACTS  1
#define INDEX_FEEDBACK      2
#define INDEX_ACCOUNT       3
#define INDEX_ABOUT         4


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
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NUMBER_OF_OPTIONS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SlideMenuTableViewCell *cell = [CellFactory cellSlideMenuTableViewCellFromTable:tableView forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case INDEX_RECENT_CONTACTS:
            cell.titleLabel.text = LOC(@"Recent Contacts", @"Title");
            cell.iconImageView.image = [UIImage imageNamed:@"icon_recent"];
            break;
        case INDEX_ALL_CONTACTS:
            cell.titleLabel.text = LOC(@"All Contacts", @"Title");
            cell.iconImageView.image = [UIImage imageNamed:@"icon_all"];
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
        case INDEX_ABOUT:
            cell.titleLabel.text = LOC(@"About", @"About");
            cell.iconImageView.image = [UIImage imageNamed:@"icon_about"];
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
    [self.reSideMenuContainerViewController hideMenuViewController];
    if(indexPath.row == INDEX_RECENT_CONTACTS) {
        UINavigationController *navigationController = (UINavigationController*)self.reSideMenuContainerViewController.contentViewController;
        ContactsViewController *contactsViewController = navigationController.viewControllers.firstObject;
        [contactsViewController resetUserInterfaceWithActiveCellTag:CELL_TAG_RECENT_CONTACTS];
        [navigationController popToRootViewControllerAnimated:YES];
    } else if (indexPath.row == INDEX_ALL_CONTACTS) {
        UINavigationController *navigationController = (UINavigationController*)self.reSideMenuContainerViewController.contentViewController;
        ContactsViewController *contactsViewController = navigationController.viewControllers.firstObject;
        [contactsViewController resetUserInterfaceWithActiveCellTag:CELL_TAG_ALL_CONTACTS];
        [navigationController popToRootViewControllerAnimated:YES];
    } else if (indexPath.row == INDEX_FEEDBACK) {
        [self.reSideMenuContainerViewController sendFeedback];
    } else if (indexPath.row == INDEX_TUTORIAL) {
        //UINavigationController *nvc = (UINavigationController*)self.reSideMenuContainerViewController.contentViewController;
        //ContactsViewController *cvc = [nvc.viewControllers firstObject];
        NSLog(@"Show tutorial....");
    } else if (indexPath.row == INDEX_ACCOUNT) {        
        UINavigationController *navigationController = (UINavigationController*)self.reSideMenuContainerViewController.contentViewController;
        
        AccountViewController *accountViewController = [AccountViewController createInstance];
        [navigationController pushViewController:accountViewController animated:YES];
    } else if (indexPath.row == INDEX_ABOUT) {
        UINavigationController *navigationController = (UINavigationController*)self.reSideMenuContainerViewController.contentViewController;
        AboutViewController *aboutViewController = [AboutViewController createInstance];
        [navigationController pushViewController:aboutViewController animated:YES];
    }
}

#pragma mark - RESideMenuDelegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
        if(peppermintMessageSender.nameSurname.length > 0) {
            self.userLabel.text = peppermintMessageSender.nameSurname;
        } else {
            self.userLabel.text = @"Peppermint";
        }
        
        if(peppermintMessageSender.imageData
           && peppermintMessageSender.imageData.length > 0) {
            self.avatarImageView.image = [UIImage imageWithData:peppermintMessageSender.imageData];
        } else {
            self.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
        }
    });
    
}

@end