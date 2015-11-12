//
//  AccountViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 12/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "AccountViewController.h"
#import "AppDelegate.h"
#import "LoginNavigationViewController.h"

#define NUMBER_OF_OPTIONS       1
#define OPTION_LOG_OUT          0

@interface AccountViewController ()

@end

@implementation AccountViewController

#pragma mark - PresentLoginModalView

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_LOGIN bundle:[NSBundle mainBundle]];
    AccountViewController *accountViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_ACCOUNT];
    return accountViewController;
}

+(void) presentAccountViewControllerWithCompletion:(void(^)(void))completion {
    UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender savedSender];
    
    if([peppermintMessageSender isValid]) {
        AccountViewController *accountViewController = [AccountViewController createInstance];
        accountViewController.peppermintMessageSender = peppermintMessageSender;
        accountViewController.iconCloseImageView.image = [UIImage imageNamed:@"icon_close"];
        [rootVC presentViewController:accountViewController animated:YES completion:completion];
    } else {
        [LoginNavigationViewController logUserInWithDelegate:nil completion:completion];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.iconCloseImageView.image = [UIImage imageNamed:@"icon_back"];
    if(!self.peppermintMessageSender) {
        self.peppermintMessageSender = [PeppermintMessageSender savedSender];
    }
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:18];
    self.titleLabel.text = [NSString stringWithFormat:
                            LOC(@"Logged in message format", @"Logged in message format"),
                            [self.peppermintMessageSender loginMethod]
                            ];
    [self.titleLabel sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableViewWidthConstraint.constant = self.view.frame.size.width / 2;
    [self.view setNeedsDisplay];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_OPTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginTableViewCell *logOutCell = [CellFactory cellLoginTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
    
    NSInteger index = indexPath.section;
    if(index == OPTION_LOG_OUT) {        
        logOutCell.loginIconImageViewWidthConstraint.constant = 0;
        logOutCell.loginIconImageView.image = nil;
        logOutCell.loginLabel.text = LOC(@"Log Out", @"Title");
        logOutCell.loginLabel.textColor = [UIColor googleLoginColor];
    }
    [logOutCell.loginLabel sizeToFit];
    return logOutCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
}

#pragma mark - LoginTableViewCellDelegate

-(void) selectedLoginTableViewCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath {
    NSInteger option = indexPath.section;
    if(option == OPTION_LOG_OUT) {
        [self.peppermintMessageSender clearSender];
        [self dismissViewControllerAnimated:YES completion:nil];
        [LoginNavigationViewController logUserInWithDelegate:nil completion:nil];
    }
}

#pragma mark - CloseButton

-(IBAction)closeButtonPressed:(id)sender {
    if(!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
