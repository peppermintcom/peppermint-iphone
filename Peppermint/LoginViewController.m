//
//  LoginViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginNavigationViewController.h"
#import "LoginWithEmailViewController.h"

#define NUMBER_OF_SECTIONS                  4
#define SECTION_LOGIN_WITH_FACEBOOK         0
#define SECTION_LOGIN_WITH_GOOGLE           1
#define SECTION_LOGIN_WITH_EMAIL_INFO       2
#define SECTION_LOGIN_WITH_EMAIL            3

#define DISTANCE_BTW_SECTIONS               24
#define PADDING_CONSTANT                    20

#define SEGUE_LOGIN_WITH_EMAIL      @"LoginWithEmailSegue"

@interface LoginViewController ()

@end

@implementation LoginViewController {
    PeppermintMessageSender *peppermintMessageSender;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.loginLabel.textColor = [UIColor whiteColor];
    self.loginLabel.font = [UIFont openSansSemiBoldFontOfSize:18];
    self.loginLabel.text = LOC(@"Please Login", @"Login Message");
    [self.loginLabel sizeToFit];
    
    peppermintMessageSender = [PeppermintMessageSender sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    LoginNavigationViewController *loginNavigationViewController = (LoginNavigationViewController*)self.navigationController;
    [loginNavigationViewController loginFinishedLoading];
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == SECTION_LOGIN_WITH_EMAIL_INFO) {
        InformationTextTableViewCell *informationTextTableViewCell = [CellFactory cellInformationTextTableViewCellFromTable:tableView forIndexPath:indexPath];
        
        informationTextTableViewCell.label.text = LOC(@"Login with email", nil);
        informationTextTableViewCell.label.numberOfLines = 0;
        informationTextTableViewCell.label.textColor = [UIColor whiteColor];
        informationTextTableViewCell.label.textAlignment = NSTextAlignmentCenter;
        informationTextTableViewCell.label.font = [UIFont openSansBoldFontOfSize:16];
        cell = informationTextTableViewCell;
    } else {
        LoginTableViewCell *loginCell = [CellFactory cellLoginTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        loginCell.rightPaddingConstraint.constant = PADDING_CONSTANT;
        loginCell.leftPaddingConstraint.constant = PADDING_CONSTANT;
        
        if(indexPath.section == SECTION_LOGIN_WITH_FACEBOOK) {
            loginCell.loginIconImageView.image = [UIImage imageNamed:@"icon_fb"];
            loginCell.loginLabel.text = LOC(@"Log In with Facebook", @"Title");
            loginCell.loginLabel.textColor = [UIColor facebookLoginColor];
        } else if (indexPath.section == SECTION_LOGIN_WITH_GOOGLE) {
            loginCell.loginIconImageView.image = [UIImage imageNamed:@"icon_google"];
            loginCell.loginLabel.text = LOC(@"Log In with Google", @"Title");
            loginCell.loginLabel.textColor = [UIColor googleLoginColor];
        } else if (indexPath.section == SECTION_LOGIN_WITH_EMAIL) {
            loginCell.loginIconImageView.image = [UIImage imageNamed:@"icon_email"];
            loginCell.loginLabel.text = LOC(@"Log In with Email", @"Title");
            loginCell.loginLabel.textColor = [UIColor emailLoginColor];
        }
        [loginCell.loginLabel sizeToFit];
        cell = loginCell;
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if(indexPath.section == SECTION_LOGIN_WITH_EMAIL_INFO) {
        height = 2*CELL_HEIGHT_INFORMATION_TABLEVIEWCELL;
    } else {
        height = CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if(section == SECTION_LOGIN_WITH_GOOGLE) {
        height = DISTANCE_BTW_SECTIONS;
    } else if (section == SECTION_LOGIN_WITH_EMAIL_INFO) {
        height = DISTANCE_BTW_SECTIONS;
    }
    return height;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = nil;
    CGFloat headerHeight = DISTANCE_BTW_SECTIONS;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, headerHeight)];
    return view;
}

#pragma mark - LoginTableViewCellDelegate

-(void) selectedLoginTableViewCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath {
    NSInteger index = indexPath.section;
    LoginNavigationViewController *loginNavigationViewController = (LoginNavigationViewController*)self.navigationController;
    if(index == SECTION_LOGIN_WITH_GOOGLE) {
        peppermintMessageSender.loginSource = LOGINSOURCE_GOOGLE;
        [loginNavigationViewController.loginModel performGoogleLogin];
    } else if (index == SECTION_LOGIN_WITH_FACEBOOK) {
        peppermintMessageSender.loginSource = LOGINSOURCE_FACEBOOK;
        [loginNavigationViewController.loginModel performFacebookLogin];
    } else if (index == SECTION_LOGIN_WITH_EMAIL) {
        peppermintMessageSender.loginSource = LOGINSOURCE_PEPPERMINT;        
        if([peppermintMessageSender isInMailVerificationProcess]) {
            [loginNavigationViewController loginRequireEmailVerification];
        } else {
            [self performSegueWithIdentifier:SEGUE_LOGIN_WITH_EMAIL sender:self];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_LOGIN_WITH_EMAIL]) {
        LoginWithEmailViewController *loginWithEmailViewController =
            (LoginWithEmailViewController*) segue.destinationViewController;
        LoginNavigationViewController *loginNavigationViewController =
            (LoginNavigationViewController*)self.navigationController;
        loginWithEmailViewController.loginModel = loginNavigationViewController.loginModel;
    }
}

@end
