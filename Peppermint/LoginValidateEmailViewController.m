//
//  LoginValidateEmailViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 09/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginValidateEmailViewController.h"

#define SEGUE_LOGIN_WITH_EMAIL      @"LoginWithEmailSegue"

#define ROW_COUNT           1
#define ROW_RESEND          0

#define REFRESH_PERIOD              1

@interface LoginValidateEmailViewController ()

@end

@implementation LoginValidateEmailViewController {
    AccountModel *accountModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    accountModel = [AccountModel sharedInstance];
    accountModel.delegate = self;
    
    self.doneLabel.font = [UIFont openSansFontOfSize:18];
    self.doneLabel.textColor = [UIColor whiteColor];
    self.doneLabel.text = LOC(@"Log Out", @"Log Out");
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSAssert(self.loginModel != nil, @"LoginModel must be defined for validation");
}

-(void) viewDidAppear:(BOOL)animated {
    [self checkIfAccountIsVerified];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ROW_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == ROW_RESEND) {
        LoginValidateEmailTableViewCell *loginValidateEmailTableViewCell = [CellFactory cellLoginValidateEmailTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        
        NSString *informationText = [NSString stringWithFormat:LOC(@"Validate Information Format",@"Validate Information"), self.loginModel.peppermintMessageSender.email];
        loginValidateEmailTableViewCell.informationLabel.text = informationText;
        [loginValidateEmailTableViewCell.informationLabel sizeToFit];
        loginValidateEmailTableViewCell.buttonTitleLabel.text = LOC(@"Resend Verification",@"Resend Verification");
        cell = loginValidateEmailTableViewCell;
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.row == ROW_RESEND) {
        height = CELL_HEIGHT_VALIDATE_EMAIL_TABLEVIEWCELL;
    }
    return height;
}

#pragma mark - LoginValidateEmailTableViewCellDelegate

-(void) resendValidation {
    [self.loginModel.delegate loginLoading];
    [accountModel resendVerificationEmail:self.loginModel.peppermintMessageSender];
}

#pragma mark - Check for Email Verification

-(void) checkIfAccountIsVerified {
    if(self.loginModel.peppermintMessageSender.isEmailVerified) {
        [self.loginModel.delegate loginSucceed];
    } else if (self.loginModel.peppermintMessageSender.accountId)  {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [accountModel refreshAccountInfo:self.loginModel.peppermintMessageSender];
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

#pragma mark - Navigation

-(IBAction) backButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction) doneButtonPressed:(id)sender {
    accountModel.delegate = nil;
    [self.loginModel.peppermintMessageSender clearSender];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue...");
}

@end
