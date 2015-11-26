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

#define WelcomeBackSegue @"WelcomeBackSegue"
#define SEGUE_SIGNUP_WITH_EMAIL      @"SignUpWithEmailSegue"

@interface LoginWithEmailViewController () <LoginTextFieldTableViewCellDelegate>

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
  
  [self setupEmailCell];
  [self setupPasswordCell];
  
  self.descriptionLabel.text = self.loginModel.peppermintMessageSender.email;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.emailCell.textField becomeFirstResponder];
  [self.passwordCell.textField becomeFirstResponder];
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

- (void)setupEmailCell {
  if (!self.emailCell) {
    return;
  }
  
}

- (void)setupPasswordCell {
  if (!self.passwordCell) {
    return;
  }
  
  [self.passwordCell.textField becomeFirstResponder];
}

- (IBAction)backButtonPressed:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continuePressed:(id)sender {
  if (isValidEmailEmptyValidation && isValidEmailFormatValidation) {
    PeppermintMessageSender *sender = self.loginModel.peppermintMessageSender;
    sender.email = self.emailCell.textField.text;
#warning API request to check if email already exists
    //[self performSegueWithIdentifier:WelcomeBackSegue sender:nil];
    [self performSegueWithIdentifier:SEGUE_SIGNUP_WITH_EMAIL sender:nil];
    //
  }
}

- (IBAction)loginPressed:(id)sender {
  
}

- (IBAction)forgetPasswordPressed:(id)sender {
  
}

#pragma mark- LoginTextFieldTableViewCellDelegate

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

@end
