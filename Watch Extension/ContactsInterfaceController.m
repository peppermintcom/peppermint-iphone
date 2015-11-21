//
//  InterfaceController.m
//  Watch Extension
//
//  Created by Yan Saraev on 11/18/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactsInterfaceController.h"
#import "ContactsTableRowController.h"
#import "WKContact.h"
#import "PeppermintContact.h"
#import "RecordingInterfaceController.h"
#import "WKInterfaceTable+IGInterfaceDataTable.h"

@interface ContactsInterfaceController() <IGInterfaceTableDataSource>

@property (strong, nonatomic) NSMutableArray * datasource;

@end


@implementation ContactsInterfaceController

- (instancetype)init
{
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)loadTableData {
  self.tableView.ig_dataSource = self;
  [self.tableView reloadData];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

  __weak typeof(self) weakSelf = self;
    // Configure interface objects here.
  [WKContact allContacts:^(NSArray * results) {
    __strong typeof(self) strongSelf = weakSelf;
    strongSelf.datasource = [results mutableCopy];
    [strongSelf loadTableData];
  }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark- IBActions

- (IBAction)searchPressed:(id)sender {
  [self presentTextInputControllerWithSuggestions:nil allowedInputMode:WKTextInputModePlain completion:^(NSArray * results) {
    NSLog(@"WK input result: %@", results);
  }];
}


#pragma mark- IGInterfaceTableDataSourceDelegate
- (NSInteger)numberOfRowsInTable:(WKInterfaceTable *)table section:(NSInteger)section {
  NSLog(@"%s: %ld", __PRETTY_FUNCTION__, (unsigned long)(unsigned long)self.datasource.count);
  return self.datasource.count;
}

- (NSString *)table:(WKInterfaceTable *)table rowIdentifierAtIndexPath:(NSIndexPath *)indexPath {
  return @"ContactsTableRowController";
}

- (void)table:(WKInterfaceTable *)table configureRowController:(NSObject *)rowController forIndexPath:(IGTableRowData *)indexPath {
  ContactsTableRowController *controller = (ContactsTableRowController *)rowController;
  PeppermintContact * ppm_contact = (PeppermintContact *)self.datasource[indexPath.row];
  [controller.titleLabel setText:ppm_contact.nameSurname];
  [controller.subtitleLabel setText:ppm_contact.communicationChannelAddress];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
  PeppermintContact * ppm_contact = (PeppermintContact *)self.datasource[rowIndex];

  [self pushControllerWithName:NSStringFromClass([RecordingInterfaceController class])
                       context:ppm_contact];
}

@end



