//
//  LoginWithEmailViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginWithEmailViewController.h"
#import "LoginNavigationViewController.h"
#import "LoginValidateEmailViewController.h"

#define NUMBER_OF_GROUPS        3
#define INDEX_NAME_SURNAME      0
#define INDEX_EMAIL             1
#define INDEX_PASSWORD          2

#define DISTANCE_BTW_SECTIONS       12

#define SEGUE_LOGIN_VALIDATE_EMAIL      @"LoginValidateEmailSegue"

@interface LoginWithEmailViewController ()
@end

@implementation LoginWithEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;    
    self.doneLabel.font = [UIFont openSansFontOfSize:18];
    self.doneLabel.textColor = [UIColor whiteColor];
    self.doneLabel.text = LOC(@"Register",@"Login button text");
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSAssert(self.loginModel != nil, @"LoginModel must be initiated before LoginWithEmailViewController is shown");
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showKeyboardForNameSurname];
}

-(void) showKeyboardForNameSurname {
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:INDEX_NAME_SURNAME inSection:0];
    LoginTextFieldTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textField becomeFirstResponder];
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_GROUPS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginTextFieldTableViewCell *loginTextFieldCell = [CellFactory cellLoginTextFieldTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
    
    NSInteger index = indexPath.section;
    if(index == INDEX_NAME_SURNAME) {
        [loginTextFieldCell.textField setSecureTextEntry:NO];
        loginTextFieldCell.textField.placeholder = LOC(@"Your Name",@"Your Name");
        loginTextFieldCell.textField.text = self.loginModel.peppermintMessageSender.nameSurname;
    } else if (index == INDEX_EMAIL) {
        [loginTextFieldCell.textField setSecureTextEntry:NO];
        loginTextFieldCell.textField.placeholder = LOC(@"Email", @"Email");
        loginTextFieldCell.textField.text = self.loginModel.peppermintMessageSender.email;
    } else if (index == INDEX_PASSWORD) {
        [loginTextFieldCell.textField setSecureTextEntry:YES];
        loginTextFieldCell.textField.placeholder = LOC(@"Password", @"Password");
        loginTextFieldCell.textField.text = self.loginModel.peppermintMessageSender.password;
    }
    return loginTextFieldCell;
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

#pragma mark - LoginTextFieldTableViewCellDelegate

-(void) updatedTextFor:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath {
    LoginTextFieldTableViewCell* loginTextCell = (LoginTextFieldTableViewCell*) cell;
    NSString *text = loginTextCell.textField.text;
    NSInteger index = indexPath.section;
    if(index == INDEX_NAME_SURNAME) {
        self.loginModel.peppermintMessageSender.nameSurname = text;
    } else if (index == INDEX_EMAIL) {
        self.loginModel.peppermintMessageSender.email = text;
    } else if (index == INDEX_PASSWORD) {
        self.loginModel.peppermintMessageSender.password = text;
    }
}

#pragma mark - Navigation

-(IBAction) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) doneButtonPressed:(id)sender {
    if([self.loginModel.peppermintMessageSender isValid]) {
        [self performSegueWithIdentifier:SEGUE_LOGIN_VALIDATE_EMAIL sender:self];
    } else {
        NSString *title = LOC(@"Information", @"Title Message");
        NSString *message = LOC(@"Register Information Missing", @"Information Message");
        NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_LOGIN_VALIDATE_EMAIL]) {
        LoginValidateEmailViewController *loginValidateEmailViewController =
        (LoginValidateEmailViewController*) segue.destinationViewController;
        loginValidateEmailViewController.loginModel = self.loginModel;
    }
}

#pragma mark - Blink Animation
#warning "Add some animation"
/*
-(void) startFlashingbutton
{
    if (buttonFlashing) return;
    buttonFlashing = YES;
    self.button.alpha = 1.0f;
    [UIView animateWithDuration:0.12
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.button.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                     }];
}

-(void) stopFlashingbutton
{
    if (!buttonFlashing) return;
    buttonFlashing = NO;
    [UIView animateWithDuration:0.12
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.button.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                     }];
}
*/

@end
