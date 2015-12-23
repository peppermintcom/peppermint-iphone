//
//  LoginValidateEmailViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 09/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginValidateEmailViewController.h"

#define SECTION_COUNT                       4
#define SECTION_RESEND_INFORMATION          0
#define SECTION_RESEND_BUTTON               1
#define SECTION_CONTACT_SUPPORT             2
#define SECTION_CANCEL_REGISTRATION         3

#define HEIGHT_FOR_HEADER_RESEND_INFORMATION          20
#define HEIGHT_FOR_HEADER_RESEND_BUTTON               0
#define HEIGHT_FOR_HEADER_CONTACT_SUPPORT             200
#define HEIGHT_FOR_HEADER_CANCEL_REGISTRATION         20

#define REFRESH_PERIOD              1

@interface LoginValidateEmailViewController ()

@end

@implementation LoginValidateEmailViewController {
    AccountModel *accountModel;
    ContactSupportModel *contactSupportModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    accountModel = [AccountModel sharedInstance];
    accountModel.delegate = self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSAssert(self.loginModel != nil, @"LoginModel must be defined for validation");
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkIfAccountIsVerified];
}

#pragma mark - Screen Size

-(BOOL) isBigScreen {
    return [UIScreen mainScreen].bounds.size.height > SCREEN_HEIGHT_LIMIT;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    UIFont *commonFont = [UIFont openSansSemiBoldFontOfSize:13];
    if([self isBigScreen]) {
        commonFont = [UIFont openSansSemiBoldFontOfSize:16];
    }
    
    if (indexPath.section == SECTION_RESEND_INFORMATION) {
        LoginValidateEmailTableViewCell *loginValidateEmailTableViewCell = [CellFactory cellLoginValidateEmailTableViewCellFromTable:tableView forIndexPath:indexPath];
        NSString *informationText = [NSString stringWithFormat:LOC(@"Validate Information Format",@"Validate Information"), [PeppermintMessageSender sharedInstance].email];
        loginValidateEmailTableViewCell.informationLabel.text = informationText;
        [loginValidateEmailTableViewCell.informationLabel sizeToFit];
        cell = loginValidateEmailTableViewCell;
    }
    else if (indexPath.section == SECTION_RESEND_BUTTON) {
        LoginTableViewCell *loginTableViewCell = [CellFactory cellLoginTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        [loginTableViewCell setJustText:LOC(@"Resend Verification",@"Resend Verification") withColor:[UIColor emailLoginColor] withFont:commonFont];
        cell = loginTableViewCell;
    }
    else if (indexPath.section == SECTION_CONTACT_SUPPORT) {
        LoginTableViewCell *loginTableViewCell = [CellFactory cellLoginTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        [loginTableViewCell setJustText:LOC(@"Contact Support",@"Contact Support") withColor:[UIColor emailLoginColor] withFont:commonFont];
        cell = loginTableViewCell;
    }
    else if (indexPath.section == SECTION_CANCEL_REGISTRATION) {
        LoginTableViewCell *loginTableViewCell = [CellFactory cellLoginTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        [loginTableViewCell setJustText:LOC(@"Cancel registration or change email",@"Cancel Button Title") withColor:[UIColor emailLoginColor] withFont:commonFont];
        cell = loginTableViewCell;
    }
    return cell;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == SECTION_RESEND_INFORMATION) {
        height = [self isBigScreen] ? HEIGHT_FOR_HEADER_RESEND_INFORMATION : 0;
    } else if(section == SECTION_RESEND_BUTTON) {
        height = HEIGHT_FOR_HEADER_RESEND_BUTTON;
    } else if (section == SECTION_CONTACT_SUPPORT) {
        height = [self isBigScreen] ? HEIGHT_FOR_HEADER_CONTACT_SUPPORT : HEIGHT_FOR_HEADER_CONTACT_SUPPORT * 0.5 ;
    } else if (section == SECTION_CANCEL_REGISTRATION) {
        height = HEIGHT_FOR_HEADER_CANCEL_REGISTRATION;
    }
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.section == SECTION_RESEND_INFORMATION) {
        height = [self isBigScreen] ? CELL_HEIGHT_VALIDATE_EMAIL_TABLEVIEWCELL : CELL_HEIGHT_VALIDATE_EMAIL_TABLEVIEWCELL * 0.75;
    } else if(indexPath.section == SECTION_RESEND_BUTTON) {
        height = CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
    } else if (indexPath.section == SECTION_CONTACT_SUPPORT) {
        height = CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
    } else if (indexPath.section == SECTION_CANCEL_REGISTRATION) {
        height = CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
    }
    return height;
}

#pragma mark - Check for Email Verification

-(void) checkIfAccountIsVerified {
    if([PeppermintMessageSender sharedInstance].isEmailVerified) {
        [self.loginModel.delegate loginSucceed];
    } else if ([PeppermintMessageSender sharedInstance].accountId)  {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [accountModel refreshAccountInfo:[PeppermintMessageSender sharedInstance]];
    } else {
        NSLog(@"User seems do not have account Id!");
    }
}

#pragma mark - AccountModelDelegate

-(void) operationFailure:(NSError*) error {
    [self.loginModel.delegate loginFinishedLoading];
    [super operationFailure:error];
}

-(void) verificationEmailSendSuccess {
    [self.loginModel.delegate loginFinishedLoading];
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Verification Mail Sent", @"Verification Mail Sent");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

-(void) accountInfoRefreshSuccess {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self performSelector:@selector(checkIfAccountIsVerified) withObject:nil afterDelay:REFRESH_PERIOD];
}

- (void)userLogInSuccessWithEmail:(NSString *)email {
    NSLog(@"userLogInSuccessWithEmail: %@", email);
}

-(void) userRegisterSuccessWithEmail:(NSString *)email password:(NSString *)password jwt:(NSString *)jwt {
    NSLog(@"userRegisterSuccessWithEmail:%@ password:%@ jwt:%@", email, password, jwt);
}

#pragma mark - LoginTableViewCellDelegate

-(void) selectedLoginTableViewCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath {
    if(indexPath.section == SECTION_RESEND_BUTTON) {
        [self.loginModel.delegate loginLoading];
        [accountModel resendVerificationEmail:[PeppermintMessageSender sharedInstance]];
    } else if (indexPath.section == SECTION_CONTACT_SUPPORT) {
        if(!contactSupportModel) {
            contactSupportModel = [ContactSupportModel new];
            contactSupportModel.delegate = self;
        }
        [contactSupportModel sendContactSupportMail];
    } else if(indexPath.section == SECTION_CANCEL_REGISTRATION) {
        accountModel.delegate = nil;
        [[PeppermintMessageSender sharedInstance] clearSender];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - ContactSupportModelDelegate

-(void) contactSupportMailSentWithSuccess {
    NSString *title = LOC(@"Information", @"Information");
    NSString *message = LOC(@"Contact support mail was sent", @"Contact support mail was sent");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue...");
}

@end
