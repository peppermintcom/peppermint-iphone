//
//  ContactsViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsViewController.h"
#import "RecordingViewController.h"
#import "SendVoiceMessageEmailModel.h"

#define SEGUE_RECORDING_VIEW_CONTROLLER @"RecordingViewControllerSegue"

@interface ContactsViewController ()

@end

@implementation ContactsViewController {
    BOOL canDeviceSendEmail;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    canDeviceSendEmail = [SendVoiceMessageEmailModel canDeviceSendEmail];
    self.contactsModel = [ContactsModel new];
    self.contactsModel.delegate = self;
    [self.contactsModel setup];
    self.searchContactsTextField.text = self.contactsModel.filterText;
    self.searchContactsTextField.placeholder = LOC(@"Search for Contacts", @"Placeholder text");
    self.searchContactsTextField.tintColor = [UIColor textFieldTintGreen];
    self.searchContactsTextField.delegate = self;
    self.loadingView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.contactsModel = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchContactsTextField becomeFirstResponder];
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
    if(self.contactsModel.contactList.count > indexPath.row) {
        PeppermintContact *selectedContact = [self.contactsModel.contactList objectAtIndex:indexPath.row];
        [self.searchContactsTextField resignFirstResponder];
        if([self shouldPerformSegueWithIdentifier:SEGUE_RECORDING_VIEW_CONTROLLER sender:selectedContact]) {
            [self performSegueWithIdentifier:SEGUE_RECORDING_VIEW_CONTROLLER sender:selectedContact];
        }
    }
}

#pragma mark - TextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.contactsModel.filterText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = self.contactsModel.filterText;
    //self.loadingView.hidden = NO;
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
    //self.loadingView.hidden = YES;
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_RECORDING_VIEW_CONTROLLER]) {
        RecordingViewController *rvc = (RecordingViewController*)segue.destinationViewController;
        PeppermintContact *selectedContact = (PeppermintContact*)sender;
        
        if(selectedContact.communicationChannel == CommunicationChannelEmail) {
            SendVoiceMessageEmailModel *sendVoiceMessageEmailModel = [SendVoiceMessageEmailModel new];
            sendVoiceMessageEmailModel.selectedPeppermintContact = selectedContact;
            sendVoiceMessageEmailModel.delegate = rvc;
            rvc.sendVoiceMessageModel = sendVoiceMessageEmailModel;
        } else if (selectedContact.communicationChannel == CommunicationChannelSMS) {
            NSLog(@"SMS functionality is not implemented yet");
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL result = YES;    
    if([identifier isEqualToString:SEGUE_RECORDING_VIEW_CONTROLLER]) {
        PeppermintContact *selectedContact = (PeppermintContact*)sender;
        if(selectedContact.communicationChannel == CommunicationChannelEmail) {
            result = canDeviceSendEmail;
            if(!result) {
                NSString *title = LOC(@"Information", @"Information");
                NSString *message = LOC(@"Please add an email account", @"Email service info");
                NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
                [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
            }
        } else if (selectedContact.communicationChannel == CommunicationChannelSMS) {
            result = NO;
            NSString *title = LOC(@"Information", @"Information");
            NSString *message = LOC(@"SMS is not implemented", @"SMS implementation info");
            NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
            [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
        }
    }
    return result;
}

@end
