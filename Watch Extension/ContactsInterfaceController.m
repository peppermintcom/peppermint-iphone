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
#import "PeppermintMessageSender.h"
#import "PeppermintContact.h"
#import "ExtensionDelegate.h"
#import "RecentContactsModel.h"
#import "AppConfigurationFile.h"
#import "WKServerManager.h"

@import WatchConnectivity;

@interface ContactsInterfaceController() <IGInterfaceTableDataSource, RecentContactsModelDelegate>

@property (strong, nonatomic) NSMutableArray * datasource;
@property (strong, nonatomic) NSMutableArray * allContacts;
@property NSURL *lastRecordingURL;

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

  // Configure interface objects here.
  self.datasource = [NSMutableArray array];
  self.allContacts = [NSMutableArray array];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
  [ExtensionDelegate Instance].recentContactsModel.delegate = self;
  [[ExtensionDelegate Instance].recentContactsModel refreshRecentContactList];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark- IBActions

- (IBAction)searchPressed:(id)sender {
  [self presentTextInputControllerWithSuggestions:nil allowedInputMode:WKTextInputModePlain completion:^(NSArray * results) {
    NSLog(@"WK input result: %@", results);
    if (!results || results.count == 0) {
      self.datasource = [self.allContacts mutableCopy];
      [self.tableView reloadData];
      return;
    }
    
    NSString * text = [results componentsJoinedByString:@" "];
    self.datasource = [[self.allContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"communicationChannelAddress contains[c] %@ OR nameSurname contains[c] %@", text, text]] mutableCopy];
    [self.tableView reloadData];
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
  [self startRecordingForContact:ppm_contact];
  
//  [self pushControllerWithName:NSStringFromClass([RecordingInterfaceController class])
//                       context:ppm_contact];
}

#pragma mark- Recording

- (IBAction)startRecordingForContact:(PeppermintContact *)contact {
  WKAudioRecorderPreset preset = WKAudioRecorderPresetNarrowBandSpeech;
  
  NSLog(@"preset: %d", preset);
  
  // Get the directory from the app group.
  NSURL *directory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:AppConfigurationApplicationGroupsPrimary];
  
  NSUInteger timeAtRecording = (NSUInteger)[NSDate timeIntervalSinceReferenceDate];
  __block NSString *recordingName = [NSString stringWithFormat:@"AudioRecording-%d.mp4", timeAtRecording];
  __block NSURL * outputURL = [directory URLByAppendingPathComponent:recordingName];
  __weak ContactsInterfaceController *weakSelf = self;
  __weak PeppermintContact *weakContact = contact;
  
  [self presentAudioRecorderControllerWithOutputURL:outputURL preset:preset options:nil completion:^(BOOL didSave, NSError * _Nullable error) {
    __strong ContactsInterfaceController *strongSelf = weakSelf;
    __strong PeppermintContact *strongContact = weakContact;
    
    if (!strongSelf) {
      return;
    }
    
    if (didSave) {
      /*
       After saving we need to move the file to our documents directory
       so that WatchConnectivity can transfer it.
       */
      NSURL *extensionDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
      
      NSURL *outputExtensionURL = [extensionDirectory URLByAppendingPathComponent:recordingName];
      
      NSError *moveError;
      
      NSLog(@"outputURL: %@", outputURL);
      NSLog(@"outputExtensionURL: %@", outputExtensionURL);
      
      // Move the file.
      BOOL success = [[NSFileManager defaultManager] moveItemAtURL:outputURL toURL:outputExtensionURL error:&moveError];
      
      if (!success) {
        NSLog(@"Failed to move the outputURL to the extension's documents direcotry: %@", error);
      }
      else {
        strongSelf.lastRecordingURL = outputExtensionURL;
        NSLog(@"lastRecordingURL: %@.", strongSelf.lastRecordingURL);
        
        // Activate the session before transferring the file.
        if ([WCSession isSupported]) {
          WCSession *session = [WCSession defaultSession];
          [session activateSession];
        }
        
        [[WCSession defaultSession] transferFile:outputExtensionURL
                                        metadata:nil];
        [self sendAudioToContact:strongContact];
      }
    }
    
    if (error) {
      NSLog(@"There was an error with the audio recording: %@.", error);
    }
  }];
}

- (IBAction)sendAudioToContact:(PeppermintContact *)contact {
  [[WKServerManager sharedManager] sendFileURL:self.lastRecordingURL
                                     recipient:contact];
}

#pragma mark- RecentContactsModelDelegate

- (void)recentPeppermintContactsRefreshed {
  NSArray * results = [ExtensionDelegate Instance].recentContactsModel.contactList;
  self.datasource = [results mutableCopy];
  self.allContacts = [results mutableCopy];
  [self loadTableData];
}

- (void)recentPeppermintContactSavedSucessfully:(PeppermintContact *)peppermintContact {
  if (![self.datasource containsObject:peppermintContact]) {
    [self.datasource addObject:peppermintContact];
  }
  
  if (![self.allContacts containsObject:peppermintContact]) {
    [self.allContacts addObject:peppermintContact];
  }
  [self loadTableData];
}

- (void)operationFailure:(NSError *)error {
  
}
@end



