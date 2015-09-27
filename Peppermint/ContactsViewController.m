//
//  ContactsViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsViewController.h"

#define SEGUE_RECORDING_VIEW_CONTROLLER @"RecordingViewControllerSegue"

@interface ContactsViewController ()

@end

@implementation ContactsViewController {
    BOOL isFirstOpen;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstOpen = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"colorfill"]];
    self.contactsModel = [ContactsModel new];
    self.contactsModel.delegate = self;
    self.searchContactsTextField.text = self.contactsModel.filterText;
    self.searchContactsTextField.placeholder = LOC(@"Search for Contacts", @"Placeholder text");
    self.searchContactsTextField.tintColor = [UIColor textFieldTintGreen];
    self.searchContactsTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.contactsModel = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(isFirstOpen) {
        isFirstOpen = NO;
        [self.searchContactsTextField becomeFirstResponder];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactsModel.contactList.count == 0 ? 1 : self.contactsModel.contactList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *preparedCell = nil;
    if(self.contactsModel.contactList.count == 0) {
        EmptyResultTableViewCell *cell = [CellFactory cellEmptyResultTableViewCellFromTable:tableView forIndexPath:indexPath];
        [cell setVisibiltyOfExplanationLabels:self.contactsModel.filterText.length > 0];
        preparedCell = cell;
    } else if (indexPath.row < self.contactsModel.contactList.count) {
        ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath];
        PeppermintContact *peppermintContact = [self.contactsModel.contactList objectAtIndex:indexPath.row];
        if(peppermintContact.avatarImage) {
            cell.avatarImageView.image = peppermintContact.avatarImage;
        } else {
            cell.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
        }        
        cell.contactNameLabel.text = peppermintContact.nameSurname;
        cell.contactViaInformationLabel.text = peppermintContact.communicationChannelAddress;
        preparedCell = cell;
    }
    return preparedCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if(self.contactsModel.contactList.count == 0) {
        height = CELL_HEIGHT_EMPTYRESULT_TABLEVIEWCELL;
    } else {
        height = CELL_HEIGHT_CONTACT_TABLEVIEWCELL;
    }
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:SEGUE_RECORDING_VIEW_CONTROLLER sender:self];
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.contactsModel.filterText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = self.contactsModel.filterText;
    [self.contactsModel refreshContactList];
    return NO;
}

#pragma mark - ContactsModelDelegate

-(void) accessRightsAreNotSupplied {
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Access rights explanation", @"Directives to give access rights") ;
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

-(void) contactListRefreshed {
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:SEGUE_RECORDING_VIEW_CONTROLLER]) {
        NSLog(@"Start Recording...");
    }
}

@end
