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

#define NUMBER_OF_LOGIN_OPTIONS             3
#define SECTION_LOGIN_WITH_FACEBOOK         0
#define SECTION_LOGIN_WITH_GOOGLE           1
#define SECTION_LOGIN_WITH_EMAIL            2

#define DISTANCE_BTW_SECTIONS               24

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
  
  self.tableView.clipsToBounds = NO;
    
    self.loginLabel.textColor = [UIColor whiteColor];
    self.loginLabel.font = [UIFont openSansSemiBoldFontOfSize:18];
    self.loginLabel.text = LOC(@"Please Login", @"Login Message");
    [self.loginLabel sizeToFit];
    
    peppermintMessageSender = [PeppermintMessageSender sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_LOGIN_OPTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginTableViewCell *loginCell = [CellFactory cellLoginTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
    
    NSInteger index = indexPath.section;
    if(index == SECTION_LOGIN_WITH_FACEBOOK) {
        loginCell.loginIconImageView.image = [UIImage imageNamed:@"icon_fb"];
        loginCell.loginLabel.text = LOC(@"Log In with Facebook", @"Title");
        loginCell.loginLabel.textColor = [UIColor facebookLoginColor];
    } else if (index == SECTION_LOGIN_WITH_GOOGLE) {
        loginCell.loginIconImageView.image = [UIImage imageNamed:@"icon_google"];
        loginCell.loginLabel.text = LOC(@"Log In with Google", @"Title");
        loginCell.loginLabel.textColor = [UIColor googleLoginColor];
    } else if (index == SECTION_LOGIN_WITH_EMAIL) {
        loginCell.loginIconImageView.image = [UIImage imageNamed:@"icon_email"];
        loginCell.loginLabel.text = LOC(@"Log In with Email", @"Title");
        loginCell.loginLabel.textColor = [UIColor emailLoginColor];
    }    
    [loginCell.loginLabel sizeToFit];
    [loginCell setNeedsDisplay];
    return loginCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  CGFloat headerHeight = DISTANCE_BTW_SECTIONS;

  if (section == SECTION_LOGIN_WITH_FACEBOOK) {
    return 0;
  } else if (section == SECTION_LOGIN_WITH_EMAIL) {
    headerHeight = 4 * DISTANCE_BTW_SECTIONS;
  }
  
  return headerHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  CGFloat headerHeight = DISTANCE_BTW_SECTIONS;

  UILabel * headerTitle;
  if (section == SECTION_LOGIN_WITH_FACEBOOK) {
    return nil;
  } else if (section == SECTION_LOGIN_WITH_EMAIL) {
    headerHeight = 4 * DISTANCE_BTW_SECTIONS;
    headerTitle = [[UILabel alloc] init];
    headerTitle.text = LOC(@"Login with email", nil);
    headerTitle.numberOfLines = 0;
    [headerTitle sizeToFit];
    headerTitle.textColor = [UIColor whiteColor];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.font = [UIFont openSansBoldFontOfSize:16];
  }

  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, headerHeight)];
  headerTitle.translatesAutoresizingMaskIntoConstraints = NO;
  if (headerTitle) {
    [view addSubview:headerTitle];
    [view pinSubview:headerTitle toEdge:NSLayoutAttributeLeft constant:-20];
    [view pinSubview:headerTitle toEdge:NSLayoutAttributeRight constant:20];
    [view pinSubview:headerTitle toEdge:NSLayoutAttributeBottom constant:-12];
  }
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
