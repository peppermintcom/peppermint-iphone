//
//  AddContactViewController.m
//  Peppermint
//
//  Created by Yan Saraev on 11/26/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "AddContactViewController.h"
#import "CountryFormatModel.h"
#import "CountryRow.h"
#import "PeppermintContact.h"
#import "AppDelegate.h"
#import "CellFactory.h"

#define HEIGHT_FOR_wARNING_CELLS    20

@import AssetsLibrary;
@import MobileCoreServices;

@interface AddContactViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CustomContactModelDelegate>

@property (strong, nonatomic) UIPickerView * countryPickerView;
@property (strong, nonatomic) CountryFormatModel * countryFormatModel;

@property (weak, nonatomic) IBOutlet UIImageView * phoneImageView;
@property (weak, nonatomic) IBOutlet UIImageView * emailImageView;
@property (weak, nonatomic) IBOutlet UIImageView * avatarImageView;

@property (weak, nonatomic) IBOutlet UITableViewCell *nameSurnameWarningCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailWarningCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneNumberWarningCell;

@property (weak, nonatomic) IBOutlet UILabel *nameSurnameWarningLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailWarningLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberWarningLabel;

@end

@implementation AddContactViewController {
    NSArray *_countriesArray;
    CustomContactModel *customContactModel;
    BOOL hasCustomAvatarImage;
    int activeServiceCall;
    NSArray *textFieldsArray;

    BOOL validateFirstNameLastName;
}

#pragma mark- Class Methods

+ (void)presentAddContactControllerWithText:(NSString*) text withDelegate:(id<AddContactViewControllerDelegate>) delegate {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  
    UINavigationController *nvc = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_ADDCONTACTNAVIGATION];
    
    UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
    [rootVC presentViewController:nvc animated:YES completion:^{
        AddContactViewController *addContactViewController = (AddContactViewController*)nvc.viewControllers.firstObject;
        addContactViewController.delegate = delegate;
        
        NSArray *suppliedWordsArray = [text.trimmedText componentsSeparatedByString:@" "];
        NSMutableArray *nameComponents = [NSMutableArray new];
        for(NSString* suppliedWord in suppliedWordsArray) {
            if([suppliedWord isValidEmail]) {
                addContactViewController.emailTextField.text = suppliedWord;
            } else {
                [nameComponents addObject:suppliedWord.capitalizedString];
            }
        }
        
        if(nameComponents.count == 0 || [nameComponents.firstObject isEqualToString:@""]) {
            NSLog(@"Could not set name cos supplied information is just empty");
            [addContactViewController.firstNameTextField becomeFirstResponder];
        } else if (nameComponents.count == 1) {
            addContactViewController.firstNameTextField.text = [nameComponents firstObject];
            [addContactViewController.lastNameTextField becomeFirstResponder];
        } else if (nameComponents.count > 1) {
            NSString *firstName = [nameComponents firstObject];
            [nameComponents removeObjectAtIndex:0];
            NSString *lastName = [nameComponents componentsJoinedByString:@" "];
            addContactViewController.firstNameTextField.text = firstName.trimmedText;
            addContactViewController.lastNameTextField.text = lastName.trimmedText;
            if(addContactViewController.emailTextField.text.length > 0) {
                [addContactViewController.phoneNumberTextField becomeFirstResponder];
            } else {
                [addContactViewController.emailTextField becomeFirstResponder];
            }
            
        }
    }];
}

#pragma mark- Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    validateFirstNameLastName = NO;
    self.tableView.bounces = NO;
  
  self.navigationController.navigationBar.shadowImage = [UIImage new];
  self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
  
  self.title = LOC(@"New Contact", @"Title");
  _countryPickerView = [[UIPickerView alloc] init];
  _countryPickerView.delegate = self;
  _countryPickerView.dataSource = self;
  self.countryCodeTextField.inputView = _countryPickerView;
  self.countryCodeTextField.delegate = self;
  
  self.countryFormatModel = [[CountryFormatModel alloc] init];
  
  self.explanationLabel.text = LOC(@"You can add a phone contact, an email contact or both", @"Information");
  self.saveContactBarButtonItem.enabled = NO;
    self.saveContactBarButtonItem.title = LOC(@"Save", @"Save operation");
    
    customContactModel = [CustomContactModel new];
    customContactModel.delegate = self;
    hasCustomAvatarImage = NO;
    
    [self updateScreen];
    textFieldsArray = [NSArray arrayWithObjects:
                       self.firstNameTextField,
                       self.lastNameTextField,
                       self.emailTextField,
                       self.phoneNumberTextField,
                       nil];
    
    for(UITextField *tf in textFieldsArray) {
        [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    self.nameSurnameWarningLabel.textColor = self.emailWarningLabel.textColor = self.phoneNumberWarningLabel.textColor = [UIColor whiteColor];
    self.nameSurnameWarningLabel.font = self.emailWarningLabel.font = self.phoneNumberWarningLabel.font = [UIFont openSansSemiBoldFontOfSize:15];
    self.nameSurnameWarningLabel.text = LOC(@"Please enter a valid name.", @"Warning Message");
    self.emailWarningLabel.text = LOC(@"Please enter a valid email.", @"Warning Message");
    self.phoneNumberWarningLabel.text = LOC(@"Please enter a valid phone number.", @"Warning Message");
    
    self.animateSectionHeaders = YES;
    [self cell:self.nameSurnameWarningCell setHeight:0];
    [self cell:self.emailWarningCell setHeight:0];
    [self cell:self.phoneNumberWarningCell setHeight:0];
    [self reloadDataAnimated:NO];
    
    self.tableView.backgroundColor =
    self.nameSurnameWarningCell.contentView.backgroundColor =
    [UIColor peppermintCancelOrange];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - CountriesArray

-(NSArray*) countriesArray {
    if(!_countriesArray) {
        _countriesArray = [self.countryFormatModel countriesList];
    }
    return _countriesArray;
}

#pragma mark- IBAction

- (IBAction)phoneCodePressed:(id)sender {
  [self.countryCodeTextField becomeFirstResponder];
}

- (IBAction)cancelPressed:(id)sender {
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveContactBarButtonItemPressed:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self saveSuppliedContact];
}

-(void) saveSuppliedContact {
    activeServiceCall = 0;
    if(self.emailImageView.highlighted) {
        activeServiceCall++;
    }
    if(self.phoneImageView.highlighted) {
        activeServiceCall++;
    }
    
    if(self.emailImageView.highlighted) {
        PeppermintContact *peppermintContact = [self createdContact];
        peppermintContact.communicationChannelAddress = self.emailTextField.text;
        peppermintContact.communicationChannel = CommunicationChannelEmail;
        [customContactModel save:peppermintContact];
    }
    if(self.phoneImageView.highlighted) {
        PeppermintContact *peppermintContact = [self createdContact];
        peppermintContact.communicationChannelAddress = self.phoneNumberTextField.text;
        peppermintContact.communicationChannel = CommunicationChannelSMS;
        [customContactModel save:peppermintContact];
    }
}

-(PeppermintContact*) createdContact {
    PeppermintContact *peppermintContact = [PeppermintContact new];
    peppermintContact.avatarImage = hasCustomAvatarImage ? self.avatarImageView.image : [UIImage imageNamed:@"avatar_empty"];
    peppermintContact.nameSurname = [[NSArray arrayWithObjects:self.firstNameTextField.text.trimmedText, self.lastNameTextField.text.trimmedText, nil] componentsJoinedByString:@" "];
    return peppermintContact;
}

- (IBAction)photoGalleryPressed:(id)sender {
  ALAuthorizationStatus galleryStatus = [ALAssetsLibrary authorizationStatus];
  UIImagePickerController * picker = [[UIImagePickerController alloc] init];
  picker.modalPresentationStyle = UIModalPresentationCurrentContext;
  picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
  picker.mediaTypes = @[(NSString *)kUTTypeImage];
  picker.delegate = self;
  if (galleryStatus == ALAuthorizationStatusAuthorized || galleryStatus == ALAuthorizationStatusNotDetermined) {
    [self presentViewController:picker animated:YES completion:nil];
  } else {
    [[[UIAlertView alloc] initWithTitle:LOC(@"Peppermint does not have access to your photos. To enable access, tap Settings and turn on Photos.", nil) message:nil delegate:self cancelButtonTitle:LOC(@"Cancel", nil) otherButtonTitles:LOC(@"Settings", nil), nil] show];
  }
}

#pragma mark- UIPickerView datasource/delegate

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  if (pickerView == self.countryPickerView){
    return self.countriesArray.count;
  }
  return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
  CountryRow * countryRow = (CountryRow *)view;
  if (!view) {
    view = [[CountryRow alloc] init];
    countryRow = (CountryRow *)view;
  }
  
  NSString * isoCode = [[self.countryFormatModel countryCodeFromDisplayName:self.countriesArray[row]] uppercaseString];
  countryRow.titleLabel.text = self.countriesArray[row];
  countryRow.iconImageView.image = [UIImage imageNamed:isoCode];
  countryRow.descriptionLabel.text = [NSString stringWithFormat:@"+%@", [self.countryFormatModel phoneCodeFromCountryCodeISO:isoCode]];
  return countryRow;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
  if (pickerView == self.countryPickerView) {
    CountryRow * countryRow = (CountryRow *)[pickerView viewForRow:row forComponent:component];
    self.countryCodeTextField.text = countryRow.descriptionLabel.text;
    self.flagImageView.image = countryRow.iconImageView.image;
  }
}

#pragma mark - Update Screen

-(void) updateScreen {
    self.phoneImageView.highlighted = self.phoneNumberTextField.text.length > 4;
    self.emailImageView.highlighted = self.emailTextField.text.length > 0 && [self.emailTextField.text isValidEmail];
    
    self.firstNameTextField.text = [self.firstNameTextField.text capitalizedString];
    self.lastNameTextField.text = [self.lastNameTextField.text capitalizedString];
    
    if([self.firstNameTextField.text    isEqualToString:@" "]) { self.firstNameTextField.text = @""; }
    if([self.lastNameTextField.text     isEqualToString:@" "]) { self.lastNameTextField.text = @""; }
    
    NSMutableCharacterSet *phoneNumberCharSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [phoneNumberCharSet addCharactersInString:INTERNATIONAL_PHONE_SIGN];
    self.phoneNumberTextField.text =
    [[self.phoneNumberTextField.text componentsSeparatedByCharactersInSet:[phoneNumberCharSet invertedSet]] componentsJoinedByString:@""];
    
    self.saveContactBarButtonItem.enabled =
    self.firstNameTextField.text.trimmedText.length > 0
    && self.lastNameTextField.text.trimmedText.length > 0
    && ((self.phoneImageView.highlighted && self.emailTextField.text.length == 0)
        || self.emailImageView.highlighted
    );
    
    self.firstNameTextField.returnKeyType =
    self.lastNameTextField.returnKeyType =
    self.phoneNumberTextField.returnKeyType =
    self.emailTextField.returnKeyType =
    self.saveContactBarButtonItem.enabled ? UIReturnKeyDone : UIReturnKeyNext;
}

-(void) updateValidationRows {
    BOOL isNameSurnameSupplied = !validateFirstNameLastName
    || (self.firstNameTextField.text.trimmedText.length > 0 && self.lastNameTextField.text.trimmedText.length > 0);
    [self cell:self.nameSurnameWarningCell setHeight:isNameSurnameSupplied ? 0 : HEIGHT_FOR_wARNING_CELLS];
    
    BOOL isEmailSupplied = self.emailTextField.text.length == 0 || self.emailImageView.highlighted;
    [self cell:self.emailWarningCell setHeight:isEmailSupplied ? 0 : HEIGHT_FOR_wARNING_CELLS];
    
    BOOL isPhoneNumberSupplied = self.phoneNumberTextField.text.length < 2 || self.phoneImageView.highlighted;
    [self cell:self.phoneNumberWarningCell setHeight:isPhoneNumberSupplied ? 0 : HEIGHT_FOR_wARNING_CELLS];
    
    [self reloadDataAnimated:YES];
}

-(void)textFieldDidChange :(UITextField *)textField {
    UIReturnKeyType returnKeyType = textField.returnKeyType;
    [self updateScreen];
    [self updateValidationRows];
    if(returnKeyType != textField.returnKeyType) {
        [textField resignFirstResponder];
        [textField becomeFirstResponder];
    }
    
    if(textField == self.firstNameTextField || textField == self.lastNameTextField) {
        [self.delegate nameFieldUpdated:[NSString stringWithFormat:@"%@ %@", self.firstNameTextField.text, self.lastNameTextField.text]];
    }
}

#pragma mark- Text Field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField != self.firstNameTextField && textField != self.lastNameTextField) {
        validateFirstNameLastName = YES;
    }
    [self updateValidationRows];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL result = NO;
    if([string isEqualToString:DONE_STRING]) {
        if(self.saveContactBarButtonItem.enabled) {
            [self saveContactBarButtonItemPressed:nil];
        } else {
            NSUInteger index = [textFieldsArray indexOfObject:textField];
            UIResponder *nextResponder = [textFieldsArray objectAtIndex:(++index%textFieldsArray.count)];
            if (nextResponder) { [nextResponder becomeFirstResponder]; }
        }
    } else {
        if (textField == self.phoneNumberTextField) {
            if (string.length == 0 && textField.text.length == 1) {
                textField.text = INTERNATIONAL_PHONE_SIGN;
            } else if (textField.text.length == 0 && string.length != 0) {
                textField.text = [NSString stringWithFormat:@"%@%@", INTERNATIONAL_PHONE_SIGN, string];
            } else if (textField.text.length + string.length <= MAX_LENGTH_FOR_PHONE_NUMBER) {
                result = YES;
            }
        } else {
            result = YES;
        }
    }
    return result;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if (textField == self.phoneNumberTextField) {
    if ([textField.text isEqualToString:@"+"]) {
      textField.text = @"";
      self.phoneImageView.highlighted = NO;
    }
  }
}

#pragma mark- UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  UIImage * image = info[UIImagePickerControllerOriginalImage];
    
    
    self.avatarImageView.image = [[[image fixOrientation] crop]
                                  resizedImageWithWidth:CELL_HEIGHT_CONTACT_TABLEVIEWCELL*2
                                  height:CELL_HEIGHT_CONTACT_TABLEVIEWCELL*2];
  hasCustomAvatarImage = (image != nil);
  [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  alertView.delegate = nil;
  if (buttonIndex != alertView.cancelButtonIndex) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
  }
}

#pragma mark- Keyboard

- (void)handleKeyboardNotification:(NSNotification *)aNote {
  CGRect frame = [aNote.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  if ([aNote.name isEqualToString:UIKeyboardWillShowNotification]) {
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(frame), 0);
  } else {
    self.tableView.contentInset = UIEdgeInsetsZero;
  }
  [self.tableView setContentOffset:CGPointZero animated:NO];
}

#pragma mark - CustomContactModelDelegate

-(void) customPeppermintContactSavedSucessfully:(PeppermintContact*) peppermintContact {
    NSLog(@"%@ for %d is saved successFully", peppermintContact.nameSurname, (int)peppermintContact.communicationChannel );
    if(--activeServiceCall == 0) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self cancelPressed:nil];
    }
}

-(void) operationFailure:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [super operationFailure:error];
}

@end
