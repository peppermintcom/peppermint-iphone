//
//  LoginValidateEmailViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 09/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginValidateEmailViewController.h"

#define SEGUE_LOGIN_WITH_EMAIL      @"LoginWithEmailSegue"

@interface LoginValidateEmailViewController ()

@end

@implementation LoginValidateEmailViewController {
    AccountModel *accountModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.doneLabel.font = [UIFont openSansFontOfSize:18];
    self.doneLabel.textColor = [UIColor whiteColor];
    //self.doneLabel.text = LOC(@"Done",@"Login button text");
    self.doneLabel.text = @"TEST:Validate!";
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSAssert(self.loginModel != nil, @"LoginModel must be defined for validation");
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LoginValidateEmailTableViewCell *loginValidateEmailTableViewCell = [CellFactory cellLoginValidateEmailTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
    
    NSString *informationText = [NSString stringWithFormat:LOC(@"Validate Information Format",@"Validate Information"), self.loginModel.peppermintMessageSender.email];
    loginValidateEmailTableViewCell.informationLabel.text = informationText;
    [loginValidateEmailTableViewCell.informationLabel sizeToFit];
    loginValidateEmailTableViewCell.buttonTitleLabel.text = LOC(@"Resend Verification",@"Resend Verification");
    
    return loginValidateEmailTableViewCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT_VALIDATE_EMAIL_TABLEVIEWCELL;
}

#pragma mark - LoginValidateEmailTableViewCellDelegate

-(void) resendValidation {
    if(!accountModel) {
        accountModel = [AccountModel new];
        accountModel.delegate = self;
    }
    [self.loginModel.delegate loginLoading];
    [accountModel resendVerificationEmail:self.loginModel.peppermintMessageSender];
}

#pragma mark - AccountModelDelegate

-(void) verificationEmailSendSuccess {
    [self.loginModel.delegate loginFinishedLoading];
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Verification Mail Sent", @"Verification Mail Sent");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

- (void)userLogInSuccessWithEmail:(NSString *)email {
    NSLog(@"userLogInSuccessWithEmail: %@", email);
}

-(void) userRegisterSuccessWithEmail:(NSString *)email password:(NSString *)password jwt:(NSString *)jwt {
    NSLog(@"userRegisterSuccessWithEmail:%@ password:%@ jwt:%@", email, password, jwt);
}

#pragma mark - Navigation

-(IBAction) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) doneButtonPressed:(id)sender {
    self.loginModel.peppermintMessageSender.isEmailVerified = YES;
    [self.loginModel.peppermintMessageSender save];
    [self.loginModel.delegate loginSucceed];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue...");
}

@end
