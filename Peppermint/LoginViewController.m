//
//  LoginViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "LoginWithEmailViewController.h"

#define NUMBER_OF_LOGIN_OPTIONS 3
#define SECTION_LOGIN_WITH_FACEBOOK 0
#define SECTION_LOGIN_WITH_GOOGLE   1
#define SECTION_LOGIN_WITH_EMAIL    2

#define DISTANCE_BTW_SECTIONS       24

#define SEGUE_LOGIN_WITH_EMAIL      @"LoginWithEmailSegue"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.loginLabel.textColor = [UIColor whiteColor];
    self.loginLabel.font = [UIFont openSansSemiBoldFontOfSize:18];
    self.loginLabel.text = LOC(@"Please Login", @"Login Message");
    [self.loginLabel sizeToFit];
    
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
    return headerHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, DISTANCE_BTW_SECTIONS)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - LoginTableViewCellDelegate

-(void) selectedLoginTableViewCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath {
    NSInteger index = indexPath.section;
    if(index == SECTION_LOGIN_WITH_GOOGLE) {
        NSLog(@"Google login");
    } else if (index == SECTION_LOGIN_WITH_FACEBOOK) {
        NSLog(@"Facebook login");
    } else if (index == SECTION_LOGIN_WITH_EMAIL) {
        [self performSegueWithIdentifier:SEGUE_LOGIN_WITH_EMAIL sender:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_LOGIN_WITH_EMAIL]) {
        
        LoginWithEmailViewController *loginWithEmailViewController = segue.destinationViewController;
        
#warning "Handle login operations..."
        
        NSLog(@"implement if needed..");
    }
}

#pragma mark - PresentLoginModalView

+(void) logUserInWithDelegate:(id<LoginViewControllerDelegate>) delegate {
    UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    LoginViewController *loginVc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    loginVc.delegate = delegate;
    [rootVC presentViewController:loginVc.navigationController animated:YES completion:^{
        NSLog(@"Login is shown!");
    }];
}

@end