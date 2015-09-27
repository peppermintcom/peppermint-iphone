//
//  RecordingViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingViewController.h"

#define MAX_RECORD_TIME 120

@interface RecordingViewController () {
    BOOL isFirstOpen;
}

@end

@implementation RecordingViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstOpen = YES;
    assert(self.sendVoiceMessageModel != nil);
    self.navigationTitleLabel.text = LOC(@"Record Message", @"Navigation title");
    self.navigationSubTitleLabel.textColor = [UIColor recordingNavigationsubTitleGreen];
    self.navigationSubTitleLabel.text = [NSString stringWithFormat:LOC(@"for ContactNameSurname", @"Label text format"), self.sendVoiceMessageModel.selectedPeppermintContact.nameSurname];
    self.seperatorView.backgroundColor = [UIColor cellSeperatorGray];
    self.recordingModel = [RecordingModel new];
    self.recordingModel.delegate = self;
    self.counterLabel.textColor = [UIColor progressCoverViewGreen];
    self.progressContainerView.backgroundColor = [UIColor progressContainerViewGray];
    self.progressContainerView.layer.cornerRadius = 45;
    [self.m13ProgressViewPie setPrimaryColor:[UIColor progressCoverViewGreen]];
    [self.m13ProgressViewPie setSecondaryColor:[UIColor clearColor]];
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
        [self rerecordButtonPressed:nil];
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
    NSData *data = [[NSData alloc] initWithContentsOfURL:self.recordingModel.fileUrl];
    [self.sendVoiceMessageModel sendVoiceMessageWithData:data];
}

#pragma mark - RecordingModel Delegate

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

#pragma mark - SendVoiceMessage Delegate

-(void) messageSentWithSuccess {
    NSString *title = LOC(@"Information", @"Information");
    NSString *message = LOC(@"Message sent with success", @"Message sent information");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] show];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView.message isEqualToString:LOC(@"Message sent with success", @"Message sent information")]) {
        [self backButtonPressed:nil];
    }
}

#pragma mark - Navigation

-(IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
