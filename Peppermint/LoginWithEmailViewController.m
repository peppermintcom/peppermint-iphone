//
//  LoginWithEmailViewController.m
//  Peppermint
//
//  Created by Yan Saraev on 11/24/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginWithEmailViewController.h"
#import "LoginModel.h"
#import "LoginTextFieldTableViewCell.h"
#import "PeppermintMessageSender.h"
#import "SignUpWithEmailViewController.h"
#import "AWSService.h"
#import "LoginNavigationViewController.h"
#import "ConnectionModel.h"

#define SEGUE_WELCOME_BACK              @"WelcomeBackSegue"
#define SEGUE_SIGNUP_WITH_EMAIL         @"SignUpWithEmailSegue"

@interface LoginWithEmailViewController () <LoginTextFieldTableViewCellDelegate, AccountModelDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet LoginTextFieldTableViewCell * emailCell;
@property (weak, nonatomic) IBOutlet LoginTextFieldTableViewCell * passwordCell;

@property (weak, nonatomic) IBOutlet UILabel * descriptionLabel;

@end


@implementation LoginWithEmailViewController {
  BOOL isValidEmailEmptyValidation, isValidEmailFormatValidation, isValidPasswordValidation;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_gradient"]];
  self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
  
  self.descriptionLabel.text = [PeppermintMessageSender sharedInstance].email;
    isValidEmailEmptyValidation = isValidEmailFormatValidation = isValidPasswordValidation = NO;
    self.emailCell.notAllowedCharactersArray = [NSArray arrayWithObject:@" "];
    self.passwordCell.notAllowedCharactersArray = [NSArray arrayWithObject:@" "];
}

-(void) viewWillAppear:(BOOL)animated {
  [[AccountModel sharedInstance] setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.emailCell.textField becomeFirstResponder];
  [self.passwordCell.textField becomeFirstResponder];
}

#pragma mark- LoginTextFieldTableViewCellDelegate

-(void) textFieldDidBeginEdiging:(UITextField*)textField {
    NSLog(@"textFieldDidBeginEditing");
}

- (void)updatedTextFor:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    LoginTextFieldTableViewCell* loginTextCell = (LoginTextFieldTableViewCell*) cell;
    if (loginTextCell == self.emailCell) {
        isValidEmailEmptyValidation = self.emailCell.textField.text.length > 0;
        isValidEmailFormatValidation = [self.emailCell.textField.text isValidEmail];
        
        [self.emailCell setValid:isValidEmailEmptyValidation && isValidEmailFormatValidation];
    } else if (loginTextCell == self.passwordCell) {
        isValidPasswordValidation = [self.passwordCell.textField.text isPasswordLengthValid];
        [self.passwordCell setValid:isValidPasswordValidation];
    }
}

-(void) doneButtonPressed {
    if(self.descriptionLabel.text.length > 0) {
        [self loginPressed:nil];
    } else {
        [self continuePressed:nil];
    }
}

#pragma mark - AccountModelDelegate

-(void) userRegisterSuccessWithEmail:(NSString*) email password:(NSString*) password jwt:(NSString*) jwt {
    NSLog(@"userRegisterSuccessWithEmail:%@ password:%@ jwt:%@", email, password, jwt);
}

-(void) userLogInSuccessWithEmail:(NSString*) email {
    LoginNavigationViewController *loginNavigationViewController = (LoginNavigationViewController*)self.navigationController;
    if([PeppermintMessageSender sharedInstance].isEmailVerified) {
        [loginNavigationViewController loginSucceed];
    } else {
        [loginNavigationViewController loginRequireEmailVerification];
    }
}

-(void) verificationEmailSendSuccess {
    NSLog(@"verificationEmailSendSuccess");
}

-(void) accountInfoRefreshSuccess {
    NSLog(@"accountInfoRefreshSuccess");
}

-(void) checkEmailIsRegisteredIsSuccess:(BOOL) isEmailRegistered isEmailVerified:(BOOL) isEmailVerified {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [PeppermintMessageSender sharedInstance].isEmailVerified = isEmailVerified;
    if(!isEmailRegistered) {
        [self performSegueWithIdentifier:SEGUE_SIGNUP_WITH_EMAIL sender:nil];
    } else {
        [self performSegueWithIdentifier:SEGUE_WELCOME_BACK sender:nil];
    }
}

-(void) recoverPasswordIsSuccess {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSString* email = [PeppermintMessageSender sharedInstance].email;
    NSString *messageFormat = LOC(@"Email recover message format", @"Email recover message format");
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = [NSString stringWithFormat:messageFormat, email];
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

- (void)operationFailure:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [super operationFailure:error];
}

#pragma mark - Forget Password

- (IBAction)forgetPasswordPressed:(id)sender {
    [self.passwordCell.textField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString* email = [PeppermintMessageSender sharedInstance].email;
    [[AccountModel sharedInstance] recoverPasswordForEmail:email];
}

#pragma mark - Navigation

- (IBAction)backButtonPressed:(id)sender {
    [self.emailCell.textField resignFirstResponder];
    [self.passwordCell.textField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continuePressed:(id)sender {
    [self.emailCell.textField resignFirstResponder];
    if (![ConnectionModel sharedInstance].isInternetReachable) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
        [self operationFailure:error];
    } else if (isValidEmailEmptyValidation && isValidEmailFormatValidation) {
        PeppermintMessageSender *sender = [PeppermintMessageSender sharedInstance];
        sender.email = self.emailCell.textField.text;
        [[AccountModel sharedInstance] checkEmailIsRegistered:sender.email];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:LOC(@"Invalid email", nil) message:nil delegate:self cancelButtonTitle:LOC(@"OK", nil) otherButtonTitles:nil] show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.destinationViewController isKindOfClass:[LoginWithEmailViewController class]]) {
    LoginWithEmailViewController * login = (LoginWithEmailViewController *)segue.destinationViewController;
    login.loginModel = self.loginModel;
  }  else if ([segue.destinationViewController isKindOfClass:[SignUpWithEmailViewController class]]) {
    SignUpWithEmailViewController * signUp = (SignUpWithEmailViewController *)segue.destinationViewController;
    signUp.loginModel = self.loginModel;
  }
}


- (IBAction)loginPressed:(id)sender {
    [self.passwordCell.textField resignFirstResponder];
  if (isValidPasswordValidation) {
    PeppermintMessageSender *sender = [PeppermintMessageSender sharedInstance];
    sender.password = self.passwordCell.textField.text;
    
    [[AccountModel sharedInstance] logUserIn:sender.email password:sender.password];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  } else {
      [[[UIAlertView alloc] initWithTitle:LOC(@"Invalid password", nil) message:nil delegate:self cancelButtonTitle:LOC(@"OK", nil) otherButtonTitles:nil] show];
  }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView.message isEqualToString:LOC(@"Invalid password", nil)]) {
        [self.passwordCell.textField becomeFirstResponder];
    } else if ([alertView.message isEqualToString:LOC(@"Invalid email", nil)]) {
        [self.emailCell.textField becomeFirstResponder];
    }
}

@end