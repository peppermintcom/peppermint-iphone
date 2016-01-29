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


#define DISTANCE_BTW_SECTIONS               14
#define PADDING_CONSTANT                    20
#define FONT_SIZE                           17

#define SEGUE_LOGIN_WITH_EMAIL      @"LoginWithEmailSegue"

@interface LoginViewController ()

@end

@implementation LoginViewController {
    PeppermintMessageSender *peppermintMessageSender;
    NSDate *referanceDate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.bounces = NO;
    
    self.loginLabel.textColor = [UIColor whiteColor];
    self.loginLabel.font = [UIFont openSansSemiBoldFontOfSize:FONT_SIZE];
    
    NSMutableAttributedString *titleText = [NSMutableAttributedString new];
    [titleText addText:LOC(@"To send a message with Peppermint", @"title") ofSize:FONT_SIZE ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:FONT_SIZE]];
    NSUInteger size = FONT_SIZE * 0.5;
    [titleText addText:@"\n\n" ofSize:size ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:size]];
    [titleText addText:LOC(@"Please Login", @"Login Message") ofSize:FONT_SIZE ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:FONT_SIZE]];
    
    [titleText centerText];
    self.loginLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.loginLabel.attributedText = titleText;
    
    peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    referanceDate = nil;
    
    NSMutableAttributedString *informationString = [NSMutableAttributedString new];
    [informationString addText:LOC(@"Don't want to create an account yet? click here", @"Message First part") ofSize:FONT_SIZE ofColor:[UIColor whiteColor] andFont:[UIFont openSansSemiBoldFontOfSize:FONT_SIZE]];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSBackgroundColorAttributeName: [UIColor clearColor]};
    NSRange range = [informationString.string rangeOfString:@"? "];
    range.location += 2;
    range.length = informationString.string.length - range.location;
    if(range.location > 0 && range.length > 0) {
        [informationString addAttributes:underlineAttribute range:range];
    }
    
    [informationString centerText];
    self.withoutLoginLabel.attributedText = informationString;
    [self.withoutLoginLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(withoutLoginLabelPressed:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        if (IS_IPHONE_5) {
            height = DISTANCE_BTW_SECTIONS * 2.3;
        } else if (IS_IPHONE_6) {
            height = DISTANCE_BTW_SECTIONS * 3;
        } else if (IS_IPHONE_6P) {
            height = DISTANCE_BTW_SECTIONS * 4;
        }
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
    
    NSLog(@"selectedLoginTableViewCell:atIndexPath:");
    
    NSDate *nowDate = [NSDate new];
    if(!referanceDate || [nowDate timeIntervalSinceDate:referanceDate] > 1) {
        referanceDate = nowDate;
        
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
}

#pragma mark - WithoutLoginLabelPressed

-(void) withoutLoginLabelPressed:(id) sender {
    NSLog(@"withoutLoginLabelPressed");
    LoginNavigationViewController *loginNavigationViewController = (LoginNavigationViewController*)self.navigationController;
    peppermintMessageSender.loginSource = LOGINSOURCE_WITHOUTLOGIN;
    [loginNavigationViewController.loginModel performWithoutLoginAuthentication];    
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
