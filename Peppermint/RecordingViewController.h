//
//  RecordingViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "RecordingModel.h"
#import "SendVoiceMessageModel.h"
#import "M13ProgressViewPie.h"

@interface RecordingViewController : BaseViewController <RecordingModelDelegate, SendVoiceMessageDelegate>
@property (strong, nonatomic) RecordingModel *recordingModel;
@property (strong, nonatomic) SendVoiceMessageModel *sendVoiceMessageModel;

@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *navigationSubTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UIView *progressContainerView;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *m13ProgressViewPie;
@property (weak, nonatomic) IBOutlet UIImageView *progressCenterImageView;


@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@property (weak, nonatomic) IBOutlet UIButton *rerecordButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

-(IBAction)rerecordButtonPressed:(id)sender;
-(IBAction)resumeButtonPressed:(id)sender;
-(IBAction)pauseButtonPressed:(id)sender;
-(IBAction)backButtonPressed:(id)sender;

-(IBAction)sendButtonDown:(id)sender;
-(IBAction)sendButtonPressed:(id)sender;
@end
