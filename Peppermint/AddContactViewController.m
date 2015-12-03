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

@import AssetsLibrary;
@import MobileCoreServices;

@interface AddContactViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIPickerView * countryPickerView;
@property (strong, nonatomic) NSArray * countriesArray;
@property (strong, nonatomic) CountryFormatModel * countryFormatModel;

@property (weak, nonatomic) IBOutlet UIImageView * phoneImageView;
@property (weak, nonatomic) IBOutlet UIImageView * emailImageView;
@property (weak, nonatomic) IBOutlet UIImageView * avatarImageView;

@property (strong, nonatomic) PeppermintContact * contact;

@end

@implementation AddContactViewController

#pragma mark- Class Methods

+ (void)presentAddContactControllerWithCompletion:(void (^)())completion {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_ADDCONTACTNAVIGATION];
    UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
    [rootVC presentViewController:vc animated:YES completion:completion];
}

#pragma mark- Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  self.navigationController.navigationBar.shadowImage = [UIImage new];
  self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
  
  _countryPickerView = [[UIPickerView alloc] init];
  _countryPickerView.delegate = self;
  _countryPickerView.dataSource = self;
  self.countryCodeTextField.inputView = _countryPickerView;
  self.countryCodeTextField.delegate = self;
  
  self.countryFormatModel = [[CountryFormatModel alloc] init];
  self.countriesArray = [self.countryFormatModel countriesList];
  
  self.explanationLabel.text = LOC(@"You can add a phone contact, an email contact or both", @"Information");
  self.saveContactBarButtonItem.enabled = NO;
    
  self.contact = [PeppermintContact new];
}

#pragma mark- IBAction

- (IBAction)phoneCodePressed:(id)sender {
  [self.countryCodeTextField becomeFirstResponder];
}

- (IBAction)cancelPressed:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveContactBarButtonItemPressed:(id)sender {
    NSLog(@"to save Contact %@", self.contact.nameSurname);
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
    self.phoneImageView.highlighted = self.phoneNumberTextField.text.length > 1;
    self.emailImageView.highlighted = self.emailTextField.text.length > 0 && [self.emailTextField.text isValidEmail];
    
    self.firstNameTextField.text = [self.firstNameTextField.text capitalizedString];
    self.lastNameTextField.text = [self.lastNameTextField.text capitalizedString];
    
    self.saveContactBarButtonItem.enabled =
    self.firstNameTextField.text.length > 0
    && self.lastNameTextField.text.length > 0
    && (self.phoneImageView.highlighted || self.emailImageView.highlighted);
}

#pragma mark- Text Field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.phoneNumberTextField) {
        if (string.length == 0 && textField.text.length == 1) {
            textField.text = @"+";
        } else if (textField.text.length == 0 && string.length != 0) {
            textField.text = [NSString stringWithFormat:@"+%@", string];
        } else {
            [textField setTextContentInRange:range replacementString:string];
        }
    } else {
        [textField setTextContentInRange:range replacementString:string];
    }
    [self updateScreen];
    return NO;
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
  self.contact.avatarImage = image;
  self.avatarImageView.image = image;
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


@end
