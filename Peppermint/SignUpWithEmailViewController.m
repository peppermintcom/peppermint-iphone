//
//  LoginWithEmailViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "SignUpWithEmailViewController.h"
#import "LoginNavigationViewController.h"
#import "LoginValidateEmailViewController.h"

#define NUMBER_OF_GROUPS        4
#define INDEX_EMAIL             0
#define INDEX_NAME              1
#define INDEX_SURNAME           2
#define INDEX_PASSWORD          3

#define ROW_COUNT_FOR_NAME                      2
#define ROW_COUNT_FOR_SURNAME                   2

#define ROW_INPUT_NAME                          0
#define ROW_NAME_EMPTY_VALIDATION               1

#define ROW_INPUT_SURNAME                       0
#define ROW_SURNAME_EMPTY_VALIDATION            1

#define ROW_COUNT_FOR_EMAIL                         3
#define ROW_INPUT_EMAIL                             0
#define ROW_EMAIL_EMPTY_VALIDATION                  1
#define ROW_EMAIL_FORMAT_VALIDATION                 2

#define ROW_COUNT_FOR_PASSWORD                      3
#define ROW_INPUT_PASSWORD                          0
#define ROW_PASSWORD_EMPTY_VALIDATION               1
#define ROW_PASSWORD_LENGTH_VALIDATION              2

#define DISTANCE_BTW_SECTIONS      12

@interface SignUpWithEmailViewController ()
@end

@implementation SignUpWithEmailViewController {
    BOOL
    isValidNameEmptyValidation,
    isValidSurnameEmptyValidation,
    isValidEmailEmptyValidation,
    isValidEmailFormatValidation,
    isValidPasswordEmptyValidation,
    isValidPassowrdLengthValidation;
    UITextField *activeTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;    
    self.doneLabel.font = [UIFont openSansFontOfSize:18];
    self.doneLabel.textColor = [UIColor whiteColor];
    self.doneLabel.text = LOC(@"Done",@"Login button text");
    
    isValidNameEmptyValidation = YES;
    isValidSurnameEmptyValidation = YES;

    isValidEmailEmptyValidation = YES;
    isValidEmailFormatValidation = YES;
    isValidPasswordEmptyValidation = YES;
    isValidPassowrdLengthValidation = YES;
    self.doneLabel.enabled = self.doneButton.enabled = NO;
    
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    peppermintMessageSender.name = peppermintMessageSender.surname = peppermintMessageSender.password = @"";
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self validateDoneButton];
    NSAssert(self.loginModel != nil, @"LoginModel must be initiated before LoginWithEmailViewController is shown");
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showKeyboardForNameSurname];
}

-(void) showKeyboardForNameSurname {
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:ROW_INPUT_NAME inSection:INDEX_NAME];
    LoginTextFieldTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textField becomeFirstResponder];
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_GROUPS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numberOfRows = 0;
    if(section == INDEX_NAME) {
        numberOfRows = ROW_COUNT_FOR_NAME;
    } else if (section == INDEX_EMAIL) {
        numberOfRows = ROW_COUNT_FOR_EMAIL;
    } else if (section == INDEX_PASSWORD) {
        numberOfRows = ROW_COUNT_FOR_PASSWORD;
    } else if (section == ROW_COUNT_FOR_SURNAME) {
      numberOfRows = ROW_COUNT_FOR_SURNAME;
    } else if (section == INDEX_SURNAME) {
      numberOfRows = ROW_COUNT_FOR_SURNAME;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell *cell = nil;
    if(indexPath.section == INDEX_NAME) {
        if(indexPath.row == ROW_INPUT_NAME) {
            LoginTextFieldTableViewCell *loginTextFieldCell = [CellFactory cellLoginTextFieldTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
            [loginTextFieldCell.textField setSecureTextEntry:NO];
            loginTextFieldCell.textField.placeholder = LOC(@"Your Name",@"Your Name");
            loginTextFieldCell.textField.keyboardType = UIKeyboardTypeAlphabet;
            loginTextFieldCell.textField.text = [PeppermintMessageSender sharedInstance].name;
            loginTextFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            cell = loginTextFieldCell;
        } else if (indexPath.row == ROW_NAME_EMPTY_VALIDATION) {
            InformationTextTableViewCell *informationTextTableViewCell = [CellFactory cellInformationTextTableViewCellFromTable:tableView forIndexPath:indexPath];
            informationTextTableViewCell.label.text = LOC(@"What is your name?",@"What is your name?");
            cell = informationTextTableViewCell;
        }
    } else if (indexPath.section == INDEX_EMAIL) {
        if(indexPath.row == ROW_INPUT_EMAIL) {
            LoginTextFieldTableViewCell *loginTextFieldCell = [CellFactory cellLoginTextFieldTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
            [loginTextFieldCell.textField setSecureTextEntry:NO];
            loginTextFieldCell.textField.placeholder = LOC(@"Email", @"Email");
            loginTextFieldCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            loginTextFieldCell.textField.text = [PeppermintMessageSender sharedInstance].email;
            loginTextFieldCell.textField.enabled = NO;
            loginTextFieldCell.textField.alpha = 0.7;
            loginTextFieldCell.notAllowedCharactersArray = [NSArray arrayWithObject:@" "];
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
            loginTextFieldCell.textField.keyboardType = UIKeyboardTypeDefault;
            loginTextFieldCell.textField.text = [PeppermintMessageSender sharedInstance].password;
            loginTextFieldCell.notAllowedCharactersArray = [NSArray arrayWithObject:@" "];
            cell = loginTextFieldCell;
        } else if (indexPath.row == ROW_PASSWORD_EMPTY_VALIDATION) {
            InformationTextTableViewCell *informationTextTableViewCell = [CellFactory cellInformationTextTableViewCellFromTable:tableView forIndexPath:indexPath];
            informationTextTableViewCell.label.text = LOC(@"This field is mandatory",@"This field is mandatory");
            cell = informationTextTableViewCell;
        } else if (indexPath.row == ROW_PASSWORD_LENGTH_VALIDATION) {
            InformationTextTableViewCell *informationTextTableViewCell = [CellFactory cellInformationTextTableViewCellFromTable:tableView forIndexPath:indexPath];
            informationTextTableViewCell.label.text = LOC(@"Please enter at least 6 characters","Please enter at least 6 characters");
            cell = informationTextTableViewCell;
        }
    } else if (indexPath.section == INDEX_SURNAME) {
      if(indexPath.row == ROW_INPUT_SURNAME) {
        LoginTextFieldTableViewCell *loginTextFieldCell = [CellFactory cellLoginTextFieldTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
        [loginTextFieldCell.textField setSecureTextEntry:NO];
        loginTextFieldCell.textField.placeholder = LOC(@"Your Surname",@"Your Surname");
        loginTextFieldCell.textField.keyboardType = UIKeyboardTypeAlphabet;
        loginTextFieldCell.textField.text = [PeppermintMessageSender sharedInstance].surname;
        loginTextFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        cell = loginTextFieldCell;
      } else if (indexPath.row == ROW_SURNAME_EMPTY_VALIDATION) {
        InformationTextTableViewCell *informationTextTableViewCell = [CellFactory cellInformationTextTableViewCellFromTable:tableView forIndexPath:indexPath];
        informationTextTableViewCell.label.text = LOC(@"What is your surname?",@"What is your surname?");
        cell = informationTextTableViewCell;
      }
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if(indexPath.section == INDEX_NAME) {
        if(indexPath.row == ROW_INPUT_NAME) {
            height = CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
        } else if (indexPath.row == ROW_NAME_EMPTY_VALIDATION) {
            height = (isValidNameEmptyValidation) ? 0 : CELL_HEIGHT_INFORMATION_TABLEVIEWCELL;
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
            height = 0; //(isValidPasswordEmptyValidation) ? 0 : CELL_HEIGHT_INFORMATION_TABLEVIEWCELL;
            //Password length validation covers empty validation
        } else if (indexPath.row == ROW_PASSWORD_LENGTH_VALIDATION) {
            height = (isValidPassowrdLengthValidation) ? 0: CELL_HEIGHT_INFORMATION_TABLEVIEWCELL;
        }
    } else if (indexPath.section == INDEX_SURNAME) {
      if(indexPath.row == ROW_INPUT_SURNAME) {
        height = CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
      } else if (indexPath.row == ROW_SURNAME_EMPTY_VALIDATION) {
        height = (isValidSurnameEmptyValidation) ? 0 : CELL_HEIGHT_INFORMATION_TABLEVIEWCELL;
      }
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 0;
    return headerHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - LoginTextFieldTableViewCellDelegate

-(void) updateKeyboardReturnKeyType {
    UIReturnKeyType currentReturnKeyType = activeTextField.returnKeyType;
    BOOL isValid = [PeppermintMessageSender sharedInstance].isValid;
    activeTextField.returnKeyType = isValid ? UIReturnKeyDone : UIReturnKeyNext;
    if(activeTextField.returnKeyType != currentReturnKeyType) {
        [activeTextField resignFirstResponder];
        [activeTextField becomeFirstResponder];
    }
}

-(void) textFieldDidBeginEdiging:(UITextField*)textField {
    activeTextField = textField;
    [self updateKeyboardReturnKeyType];
}

-(void) updatedTextFor:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath {
    LoginTextFieldTableViewCell* loginTextCell = (LoginTextFieldTableViewCell*) cell;
    activeTextField = loginTextCell.textField;
    
    NSString *text = loginTextCell.textField.text;
    NSInteger index = indexPath.section;
    if(index == INDEX_NAME) {
        loginTextCell.textField.text = [text capitalizedString];
        [PeppermintMessageSender sharedInstance].name = text;
        [self validateCellForName:loginTextCell];
    } else if (index == INDEX_EMAIL) {
        [PeppermintMessageSender sharedInstance].email = text;
        [self validateCellForEmail:loginTextCell];
    } else if (index == INDEX_PASSWORD) {
        [PeppermintMessageSender sharedInstance].password = text;
        [self validateCellForPassword:loginTextCell];
    } else if (index == INDEX_SURNAME) {
      loginTextCell.textField.text = [text capitalizedString];
      [PeppermintMessageSender sharedInstance].surname = text;
      [self validateCellForSurname:loginTextCell];
    }
    
    [self updateKeyboardReturnKeyType];
}

-(void) doneButtonPressed {
    if([[PeppermintMessageSender sharedInstance] isValid]) {
        [self doneButtonPressed:nil];
    } else {
        LoginTextFieldTableViewCell *name = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_INPUT_NAME inSection:INDEX_NAME]];
        LoginTextFieldTableViewCell *surname = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_INPUT_SURNAME inSection:INDEX_SURNAME]];
        LoginTextFieldTableViewCell *password = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_INPUT_PASSWORD inSection:INDEX_PASSWORD]];
        
        if(activeTextField == name.textField) {
            [surname.textField becomeFirstResponder];
        } else if (activeTextField == surname.textField) {
            [password.textField becomeFirstResponder];
        } else if (activeTextField == password.textField) {
            [name.textField becomeFirstResponder];
        } else {
            [activeTextField resignFirstResponder];
        }
    }
}

#pragma mark - Validation

-(void) validateCellForName:(LoginTextFieldTableViewCell*) cell {
    PeppermintMessageSender *sender = [PeppermintMessageSender sharedInstance];
    isValidNameEmptyValidation = sender.name.trimmedText.length > 0;
    
    [self validateDoneButton];
    [cell setValid:isValidNameEmptyValidation];
  
    NSMutableArray *indexpathsToReload = [NSMutableArray new];
    [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_NAME_EMPTY_VALIDATION inSection:INDEX_NAME]];
    [self.tableView reloadRowsAtIndexPaths:indexpathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) validateCellForSurname:(LoginTextFieldTableViewCell*) cell {
  PeppermintMessageSender *sender = [PeppermintMessageSender sharedInstance];
  isValidSurnameEmptyValidation = sender.surname.trimmedText.length > 0;
  
  [self validateDoneButton];
  [cell setValid:isValidSurnameEmptyValidation];
  
  NSMutableArray *indexpathsToReload = [NSMutableArray new];
  [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_SURNAME_EMPTY_VALIDATION inSection:INDEX_SURNAME]];
  [self.tableView reloadRowsAtIndexPaths:indexpathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) validateCellForEmail:(LoginTextFieldTableViewCell*) cell {
    PeppermintMessageSender *sender = [PeppermintMessageSender sharedInstance];
    isValidEmailEmptyValidation = sender.email.trimmedText.length > 0;
    isValidEmailFormatValidation = [sender.email isValidEmail];
    
    [self validateDoneButton];
    [cell setValid:isValidEmailEmptyValidation && isValidEmailFormatValidation];
    
    NSMutableArray *indexpathsToReload = [NSMutableArray new];
    [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_EMAIL_EMPTY_VALIDATION inSection:INDEX_EMAIL]];
    [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_EMAIL_FORMAT_VALIDATION inSection:INDEX_EMAIL]];
    [self.tableView reloadRowsAtIndexPaths:indexpathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) validateCellForPassword:(LoginTextFieldTableViewCell*) cell {
    PeppermintMessageSender *sender = [PeppermintMessageSender sharedInstance];
    isValidPasswordEmptyValidation = sender.password.trimmedText.length > 0 ;
    isValidPassowrdLengthValidation = [sender.password isPasswordLengthValid];
    
    BOOL isValid = isValidPasswordEmptyValidation && isValidPassowrdLengthValidation;
    [self validateDoneButton];
    [cell setValid:isValid];
    
    NSMutableArray *indexpathsToReload = [NSMutableArray new];
    [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_PASSWORD_EMPTY_VALIDATION inSection:INDEX_PASSWORD]];
    [indexpathsToReload addObject:[NSIndexPath indexPathForItem:ROW_PASSWORD_LENGTH_VALIDATION inSection:INDEX_PASSWORD]];
    [self.tableView reloadRowsAtIndexPaths:indexpathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) validateDoneButton {
    self.doneLabel.enabled = self.doneButton.enabled = [PeppermintMessageSender sharedInstance].isValid;
}

#pragma mark - Navigation

-(IBAction) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) doneButtonPressed:(id)sender {
    [activeTextField resignFirstResponder];
    if([[PeppermintMessageSender sharedInstance] isValid]) {
        [self.loginModel performEmailSignUp];
    } else {
        NSString *title = LOC(@"Information", @"Title Message");
        NSString *message = LOC(@"Register Information Missing", @"Information Message");
        NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
    }
}

#pragma mark- Notification

- (void)handleKeyboardNotification:(NSNotification *)aNote {
  CGRect frame = [aNote.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  if ([aNote.name isEqualToString:UIKeyboardWillShowNotification]) {
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(frame), 0);
  } else {
    self.tableView.contentInset = UIEdgeInsetsZero;
  }
}

@end
