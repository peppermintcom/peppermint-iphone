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

#define ROW_COUNT_FOR_NAME_SURNAME                  2
#define ROW_INPUT_NAME_SURNAME                      0
#define ROW_NAME_SURNAME_EMPTY_VALIDATION           1

#define ROW_COUNT_FOR_EMAIL                         3
#define ROW_INPUT_EMAIL                             0
#define ROW_EMAIL_EMPTY_VALIDATION                  1
#define ROW_EMAIL_FORMAT_VALIDATION                 2

#define ROW_COUNT_FOR_PASSWORD                      2
#define ROW_INPUT_PASSWORD                          0
#define ROW_PASSWORD_EMPTY_VALIDATION               1

#define DISTANCE_BTW_SECTIONS      12

#define SEGUE_LOGIN_VALIDATE_EMAIL      @"LoginValidateEmailSegue"

@interface LoginWithEmailViewController ()
@end

@implementation LoginWithEmailViewController {
    BOOL
    isValidNameSurnameEmptyValidation,
    isValidEmailEmptyValidation,
    isValidEmailFormatValidation,
    isValidPasswordEmptyValidation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;    
    self.doneLabel.font = [UIFont openSansFontOfSize:18];
    self.doneLabel.textColor = [UIColor whiteColor];
    self.doneLabel.text = LOC(@"Register",@"Login button text");
    
    isValidNameSurnameEmptyValidation = YES;
    isValidEmailEmptyValidation = YES;
    isValidEmailFormatValidation = YES;
    isValidPasswordEmptyValidation = YES;
    self.doneLabel.enabled = self.doneButton.enabled = NO;
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
    int numberOfRows = 0;
    if(section == INDEX_NAME_SURNAME) {
        numberOfRows = ROW_COUNT_FOR_NAME_SURNAME;
    } else if (section == INDEX_EMAIL) {
        numberOfRows = ROW_COUNT_FOR_EMAIL;
    } else if (section == INDEX_PASSWORD) {
        numberOfRows = ROW_COUNT_FOR_PASSWORD;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell *cell = nil;
    if(indexPath.section == INDEX_NAME_SURNAME) {
        if(indexPath.row == ROW_INPUT_NAME_SURNAME) {
            LoginTextFieldTableViewCell *loginTextFieldCell = [CellFactory cellLoginTextFieldTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
            [loginTextFieldCell.textField setSecureTextEntry:NO];
            loginTextFieldCell.textField.placeholder = LOC(@"Your Name",@"Your Name");
            loginTextFieldCell.textField.keyboardType = UIKeyboardTypeAlphabet;
            loginTextFieldCell.textField.text = self.loginModel.peppermintMessageSender.nameSurname;
            [loginTextFieldCell setTitles:[NSArray arrayWithObjects:@"Mr",@"Mrs",@"Miss", nil]];
            cell = loginTextFieldCell;
        } else if (indexPath.row == ROW_NAME_SURNAME_EMPTY_VALIDATION) {
            InformationTextTableViewCell *informationTextTableViewCell = [CellFactory cellInformationTextTableViewCellFromTable:tableView forIndexPath:indexPath];
            informationTextTableViewCell.label.text = LOC(@"This field is mandatory",@"This field is mandatory");
            cell = informationTextTableViewCell;
        }
    } else if (indexPath.section == INDEX_EMAIL) {
        if(indexPath.row == ROW_INPUT_EMAIL) {
            LoginTextFieldTableViewCell *loginTextFieldCell = [CellFactory cellLoginTextFieldTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
            [loginTextFieldCell.textField setSecureTextEntry:NO];
            loginTextFieldCell.textField.placeholder = LOC(@"Email", @"Email");
            loginTextFieldCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            loginTextFieldCell.textField.text = self.loginModel.peppermintMessageSender.email;
            [loginTextFieldCell setTitles:nil];
            cell = loginTextFieldCell;
        } else if (indexPath.row == ROW_EMAIL_EMPTY_VALIDATION) {
            InformationTextTableViewCell *informationTextTableViewCell = [CellFactory cellInformationTextTableViewCellFromTable:tableView forIndexPath:indexPath];
            informationTextTableViewCell.label.text = LOC(@"This field is mandatory",@"This field is mandatory");
            cell = informationTextTableViewCell;
        } else if (indexPath.row == ROW_EMAIL_FORMAT_VALIDATION) {
            InformationTextTableViewCell *informationTextTableViewCell = [CellFactory cellInformationTextTableViewCellFromTable:tableView forIndexPath:indexPath];
            informationTextTableViewCell.label.text = LOC(@"Mail Format is not correct",@"Mail Format is not correct");
            cell = informationTextTableViewCell;
        }
    } else if (indexPath.section == INDEX_PASSWORD) {
        if(indexPath.row == ROW_INPUT_PASSWORD) {
            LoginTextFieldTableViewCell *loginTextFieldCell = [CellFactory cellLoginTextFieldTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
            [loginTextFieldCell.textField setSecureTextEntry:YES];
            loginTextFieldCell.textField.placeholder = LOC(@"Password", @"Password");
            loginTextFieldCell.textField.keyboardType = UIKeyboardTypeNamePhonePad;
            loginTextFieldCell.textField.text = self.loginModel.peppermintMessageSender.password;
            [loginTextFieldCell setTitles:nil];
            cell = loginTextFieldCell;
        } else if (indexPath.row == ROW_PASSWORD_EMPTY_VALIDATION) {
            InformationTextTableViewCell *informationTextTableViewCell = [CellFactory cellInformationTextTableViewCellFromTable:tableView forIndexPath:indexPath];
            informationTextTableViewCell.label.text = LOC(@"This field is mandatory",@"This field is mandatory");
            cell = informationTextTableViewCell;
        }
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if(indexPath.section == INDEX_NAME_SURNAME) {
        if(indexPath.row == ROW_INPUT_NAME_SURNAME) {
            height = CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
        } else if (indexPath.row == ROW_NAME_SURNAME_EMPTY_VALIDATION) {
            height = (isValidNameSurnameEmptyValidation) ? 0 : CELL_HEIGHT_INFORMATION_TABLEVIEWCELL;
        }
    } else if (indexPath.section == INDEX_EMAIL) {
        if(indexPath.row == ROW_INPUT_EMAIL) {
            height = CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
        } else if (indexPath.row == ROW_EMAIL_EMPTY_VALIDATION) {
            height = (isValidEmailEmptyValidation) ? 0 : CELL_HEIGHT_INFORMATION_TABLEVIEWCELL;
        } else if (indexPath.row == ROW_EMAIL_FORMAT_VALIDATION) {
            height = (isValidEmailFormatValidation) ? 0 : CELL_HEIGHT_INFORMATION_TABLEVIEWCELL;
        }
    } else if (indexPath.section == INDEX_PASSWORD) {
        if(indexPath.row == ROW_INPUT_PASSWORD) {
            height = CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
        } else if (indexPath.row == ROW_PASSWORD_EMPTY_VALIDATION) {
            height = (isValidPasswordEmptyValidation) ? 0 : CELL_HEIGHT_INFORMATION_TABLEVIEWCELL;
        }
    }
    return height;
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
        [self validateCellForNameSurname:loginTextCell];
    } else if (index == INDEX_EMAIL) {
        self.loginModel.peppermintMessageSender.email = text;
        [self validateCellForEmail:loginTextCell];
    } else if (index == INDEX_PASSWORD) {
        self.loginModel.peppermintMessageSender.password = text;
        [self validateCellForPassword:loginTextCell];
    }
}

#pragma mark - Validation

-(void) validateCellForNameSurname:(LoginTextFieldTableViewCell*) cell {
    PeppermintMessageSender *sender = self.loginModel.peppermintMessageSender;
    isValidNameSurnameEmptyValidation = sender.nameSurname.length > 0;
    
    [self validateDoneButton];
    [cell setValid:isValidNameSurnameEmptyValidation];
    
    NSMutableArray *indexpathsToReload = [NSMutableArray new];
    [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_NAME_SURNAME_EMPTY_VALIDATION inSection:INDEX_NAME_SURNAME]];
    [self.tableView reloadRowsAtIndexPaths:indexpathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) validateCellForEmail:(LoginTextFieldTableViewCell*) cell {
    PeppermintMessageSender *sender = self.loginModel.peppermintMessageSender;
    isValidEmailEmptyValidation = sender.email.length > 0;
    isValidEmailFormatValidation = [sender.email isValidEmail];
    
    [self validateDoneButton];
    [cell setValid:isValidEmailEmptyValidation && isValidEmailFormatValidation];
    
    NSMutableArray *indexpathsToReload = [NSMutableArray new];
    [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_EMAIL_EMPTY_VALIDATION inSection:INDEX_EMAIL]];
    [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_EMAIL_FORMAT_VALIDATION inSection:INDEX_EMAIL]];
    [self.tableView reloadRowsAtIndexPaths:indexpathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) validateCellForPassword:(LoginTextFieldTableViewCell*) cell {
    PeppermintMessageSender *sender = self.loginModel.peppermintMessageSender;
    isValidPasswordEmptyValidation = sender.password.length > 0 ;
    
    [self validateDoneButton];
    [cell setValid:isValidPasswordEmptyValidation];
    
    NSMutableArray *indexpathsToReload = [NSMutableArray new];
    [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_PASSWORD_EMPTY_VALIDATION inSection:INDEX_PASSWORD]];
    [self.tableView reloadRowsAtIndexPaths:indexpathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) validateDoneButton {
    self.doneLabel.enabled = self.doneButton.enabled =
    isValidNameSurnameEmptyValidation
    &&isValidEmailEmptyValidation
    &&isValidEmailFormatValidation
    &&isValidPasswordEmptyValidation;
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

@end
