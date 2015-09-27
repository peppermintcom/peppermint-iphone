//
//  RecordingViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingViewController.h"

@interface RecordingViewController ()

@end

@implementation RecordingViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    assert(self.sendVoiceMessageModel != nil);
    self.navigationTitleLabel.text = LOC(@"Record Message", @"Navigation title");
    self.navigationSubTitleLabel.textColor = [UIColor recordingNavigationsubTitleGreen];
    self.navigationSubTitleLabel.text = [NSString stringWithFormat:LOC(@"for ContactNameSurname", @"Label text format"), self.sendVoiceMessageModel.selectedPeppermintContact.nameSurname];
    self.seperatorView.backgroundColor = [UIColor cellSeperatorGray];
    
    self.recordingModel = [RecordingModel new];
    self.recordingModel.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.recordingModel = nil;
    self.sendVoiceMessageModel = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self rerecordButtonPressed:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.recordingModel stop];
    NSLog(@"recording stopped!");
    [super viewWillDisappear:animated];
}

#pragma mark - Button Actions

-(IBAction)rerecordButtonPressed:(id)sender {
    [self timerUpdated:0];
    [self.recordingModel stop];
    [self.recordingModel record];
    self.pauseButton.hidden = NO;
    self.resumeButton.hidden = YES;
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

-(IBAction)sendButtonPressed:(id)sender {
    [self.recordingModel stop];
    [self.sendVoiceMessageModel sendVoiceMessageatURL:self.recordingModel.fileUrl];
}

#pragma mark - Recording Model Delegate

-(void) timerUpdated:(NSTimeInterval) timeInterval {
    int totalSeconds = (int)timeInterval;
    int minutes = totalSeconds / 60;
    int seconds = totalSeconds % 60;
    self.counterLabel.text = [NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds];
}

#pragma mark - Navigation

-(IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
