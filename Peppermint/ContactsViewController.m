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
    self.searchContactsTextField.text = @"";
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
        [cell setVisibiltyOfExplanationLabels:(!isFirstOpen)];
        preparedCell = cell;
    } else if (indexPath.row < self.contactsModel.contactList.count) {
        ContactTableViewCell *cell = [CellFactory cellContactTableViewCellFromTable:tableView forIndexPath:indexPath];
        Contact *contact = [self.contactsModel.contactList objectAtIndex:indexPath.row];
        cell.avatarImageView.image = contact.avatarImage;
        cell.contactNameLabel.text = contact.nameSurname;
        cell.contactViaInformationLabel.text = contact.communicationChannelAddress;
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
    
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSLog(@"Text changed");
    
    [self.tableView reloadData];
    
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:SEGUE_RECORDING_VIEW_CONTROLLER]) {
        NSLog(@"Start Recording...");
    }
}

@end
