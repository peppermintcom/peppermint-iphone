//
//  RecordingInterfaceController.m
//  Peppermint
//
//  Created by Yan Saraev on 11/21/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingInterfaceController.h"
#import "PeppermintContact.h"
#import "PeppermintMessageSender.h"
#import "WKServerManager.h"
#import "AppConfigurationFile.h"

@import WatchConnectivity;

@interface RecordingInterfaceController ()

@property NSURL *lastRecordingURL;
@property (strong, nonatomic) PeppermintContact * ppm_contact;

@end

@implementation RecordingInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
  if ([context isKindOfClass:[PeppermintContact class]]) {
    PeppermintContact * ppm_contact = (PeppermintContact *)context;
    self.displayName.text = ppm_contact.nameSurname;
    self.ppm_contact = ppm_contact;
  }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)startRecording {
  WKAudioRecorderPreset preset = WKAudioRecorderPresetNarrowBandSpeech;
  
  NSLog(@"preset: %d", preset);
  
  // Get the directory from the app group.
  NSURL *directory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:AppConfigurationApplicationGroupsPrimary];

  NSUInteger timeAtRecording = (NSUInteger)[NSDate timeIntervalSinceReferenceDate];
  __block NSString *recordingName = [NSString stringWithFormat:@"AudioRecording-%d.mp4", timeAtRecording];
  __block NSURL * outputURL = [directory URLByAppendingPathComponent:recordingName];
  __weak RecordingInterfaceController *weakSelf = self;
  [self presentAudioRecorderControllerWithOutputURL:outputURL preset:preset options:nil completion:^(BOOL didSave, NSError * _Nullable error) {
    __strong RecordingInterfaceController *strongSelf = weakSelf;
    
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

        [[WCSession defaultSession] transferFile:outputExtensionURL metadata:nil];
      }
    }
    
    if (error) {
      NSLog(@"There was an error with the audio recording: %@.", error);
    }
  }];
}

- (IBAction)sendPressed:(id)sender {
  [[WKServerManager sharedManager] sendFileURL:self.lastRecordingURL recipient:self.ppm_contact];
}

@end



