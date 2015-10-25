//
//  RecordingViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingViewController.h"
#import "ContactsViewController.h"

@interface RecordingViewController () {
    BOOL isFirstOpen;
    UIAlertView *microphoneAccessAlertView;
}

@end

@implementation RecordingViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstOpen = YES;
    microphoneAccessAlertView = nil;
    assert(self.sendVoiceMessageModel != nil);
    self.navigationTitleLabel.text = LOC(@"Record Message", @"Navigation title");
    self.navigationSubTitleLabel.textColor = [UIColor recordingNavigationsubTitleGreen];
    self.navigationSubTitleLabel.text = [NSString stringWithFormat:LOC(@"for ContactNameSurname", @"Label text format"), self.sendVoiceMessageModel.selectedPeppermintContact.nameSurname];
    self.seperatorView.backgroundColor = [UIColor cellSeperatorGray];
    self.recordingModel = [RecordingModel new];
    [RecordingModel setPreviousFileLength:0];
    self.recordingModel.delegate = self;
    self.counterLabel.textColor = [UIColor progressCoverViewGreen];
    self.progressContainerView.backgroundColor = [UIColor progressContainerViewGray];
    self.progressContainerView.layer.cornerRadius = 45;
    [self.m13ProgressViewPie setPrimaryColor:[UIColor progressCoverViewGreen]];
    [self.m13ProgressViewPie setSecondaryColor:[UIColor clearColor]];
    [self registerAppNotifications];
}

-(void)dealloc {
    [self deRegisterAppNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.recordingModel = nil;
    self.sendVoiceMessageModel = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(isFirstOpen) {
        isFirstOpen = NO;
        if(self.recordingModel.grantedForMicrophone) {
            [self rerecordButtonPressed:nil];
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.recordingModel stop];
    [super viewWillDisappear:animated];
}

#pragma mark - Button Actions

-(IBAction)rerecordButtonPressed:(id)sender {
    [self timerUpdated:0];
    [self.recordingModel stop];
    [self.recordingModel record];
    self.pauseButton.hidden = NO;
    self.resumeButton.hidden = YES;
    self.resumeButton.enabled = YES;
    self.pauseButton.enabled = YES;
    self.sendButton.enabled = NO;
    [self performSelector:@selector(enableSendButton) withObject:nil afterDelay:MIN_VOICE_MESSAGE_LENGTH];
}

-(void) enableSendButton {
    self.sendButton.enabled = YES;
}

-(IBAction)resumeButtonPressed:(id)sender {
    [self.recordingModel resume];
    self.resumeButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

-(IBAction)pauseButtonPressed:(id)sender {
    [self.recordingModel pause];
    self.pauseButton.hidden = YES;
    self.resumeButton.hidden = NO;
}

-(IBAction)sendButtonDown:(id)sender {
    self.progressCenterImageView.image = [UIImage imageNamed:@"recording_logo_pressed"];
}

-(IBAction)sendButtonPressed:(id)sender {
    self.progressCenterImageView.image = [UIImage imageNamed:@"recording_logo"];
    self.resumeButton.enabled = NO;
    self.pauseButton.enabled = NO;
    [self.recordingModel stop];
    [self.recordingModel prepareRecordData];
}

#pragma mark - RecordingModel Delegate

-(void) microphoneAccessRightsAreNotSupplied {
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Mic Access rights explanation", @"Directives to give access rights") ;
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    NSString *settingsButtonTitle = LOC(@"Settings", @"Settings Message");
    microphoneAccessAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:settingsButtonTitle, nil];
    [microphoneAccessAlertView show];
}

-(void) accessRightsAreSupplied {
    if([RecordingModel checkPreviousFileLength] < 0.01) {
        [self rerecordButtonPressed:nil];
    }
}

-(void) timerUpdated:(NSTimeInterval) timeInterval {
    int totalSeconds = (int)timeInterval;
    if(totalSeconds < MAX_RECORD_TIME) {
        if(totalSeconds/5 % 2 == 0 ) {
            self.progressCenterImageView.image = [UIImage imageNamed:@"recording_logo"];
        } else {
            self.progressCenterImageView.image = [UIImage imageNamed:@"recording_logo_right"];
        }
        int minutes = totalSeconds / 60;
        int seconds = totalSeconds % 60;
        self.counterLabel.text = [NSString stringWithFormat:@"%.1d:%.2d", minutes, seconds];
        [self.m13ProgressViewPie setProgress:timeInterval/MAX_RECORD_TIME animated:NO];
    } else {
        [self.recordingModel stop];
        self.resumeButton.enabled = NO;
        self.pauseButton.enabled = NO;
        [self showTimeFinishedInformation];
    }
}

- (void) showTimeFinishedInformation {
    NSString *title = LOC(@"Information", @"Information");
    NSString *message = LOC(@"Time is up", @"Max time reached information message");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

- (void) recordDataIsPrepared:(NSData *)data withExtension:(NSString *)extension{
    [self.sendVoiceMessageModel sendVoiceMessageWithData:data withExtension:extension];
}

#pragma mark - SendVoiceMessage Delegate

-(void) messageIsSending {
    ContactsViewController *contactsViewController = (ContactsViewController*)[self backViewController];
    [contactsViewController messageSendingIndicatorSetMessageIsSending];
}

-(void) messageSentWithSuccess {
    ContactsViewController *contactsViewController = (ContactsViewController*)[self backViewController];
    [contactsViewController messageSendingIndicatorSetMessageIsSent];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView == microphoneAccessAlertView) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self redirectToSettingsPageForPermission];
                break;
            default:
                break;
        }
    } else if([alertView.message isEqualToString:LOC(@"Message sent with success", @"Message sent information")]) {
        [self backButtonPressed:nil];
    } else if ([alertView.message isEqualToString:LOC(@"Recording is cut", @"Recording is cut, how to continue question?")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_CANCEL:
                [self.recordingModel resetRecording];
                break;
            case ALERT_BUTTON_INDEX_OTHER_1:
                break;
            default:
                break;
        }
        [self.recordingModel record];
    }
}

#pragma mark - App Interruption Actions

-(void) registerAppNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

-(void) deRegisterAppNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationWillResignActiveNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
}

-(void) applicationWillResignActive {
    [self.recordingModel backUpRecording];
}

-(void) applicationDidBecomeActive {
    self.recordingModel = [RecordingModel new];
    CGFloat previousFileLength = [RecordingModel checkPreviousFileLength];
    [self timerUpdated:previousFileLength];
    self.recordingModel.delegate = self;
    
    NSString *title = LOC(@"Information", @"Information");
    NSString *message = LOC(@"Recording is cut", @"Recording is cut, how to continue question?");
    NSString *newRecordButtonTitle = LOC(@"Restart record", @"Restart record button title");
    NSString *continueFromPreviousButtonTitle = LOC(@"Continue from previous", @"Continue from previous button title");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:newRecordButtonTitle otherButtonTitles:continueFromPreviousButtonTitle, nil] show];
}

#pragma mark - Navigation

-(IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end