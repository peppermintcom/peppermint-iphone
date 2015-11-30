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

@property (copy, nonatomic) void(^completion)(void);

@property (strong, nonatomic) PeppermintContact * contact;

@end

@implementation AddContactViewController

#pragma mark- Class Methods

+ (void)presentAddContactControllerWithCompletion:(void (^)())completion {
  UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  UINavigationController * navigationController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AddContactViewController class])];
  AddContactViewController * addContactViewController = (AddContactViewController *)navigationController.viewControllers.firstObject;
  addContactViewController.completion = completion;

  UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
  [rootVC presentViewController:navigationController animated:YES completion:nil];
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
    
  [[UITextField appearance] setTintColor:[UIColor textFieldTintGreen]];
  
  self.contact = [PeppermintContact new];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:; forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark- IBAction

- (IBAction)phoneCodePressed:(id)sender {
  [self.countryCodeTextField becomeFirstResponder];
}

- (IBAction)cancelPressed:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark- Text Field delegate

- (IBAction)textFieldDidChange:(UITextField *)textField {
  if (textField == self.emailTextField) {
    self.emailImageView.highlighted = textField.text.length > 0 && [textField.text isValidEmail];
  } else if (textField == self.phoneNumberTextField) {
    self.phoneImageView.highlighted = textField.text.length > 0;
  } else if (textField == self.lastNameTextField) {
    
  } else {
    
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (textField == self.phoneNumberTextField) {
    if (string.length == 0 && textField.text.length == 1) {
      textField.text = @"+";
      return NO;
    } else if (textField.text.length == 0 && string.length != 0) {
      textField.text = [NSString stringWithFormat:@"+%@", string];
      return NO;
    }
    return YES;
  } else {
    return YES;
  }
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
}


@end
