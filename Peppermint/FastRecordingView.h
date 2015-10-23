//
//  FastRecordingView.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCustomView.h"
#import "RecordingModel.h"
#import "SendVoiceMessageModel.h"
#import "M13ProgressViewPie.h"
#import "ExplodingView.h"

@protocol FastRecordingViewDelegate <SendVoiceMessageDelegate>
@end

@interface FastRecordingView : BaseCustomView <RecordingModelDelegate, SendVoiceMessageDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) UIViewController<FastRecordingViewDelegate>* delegate;
@property (strong, nonatomic) RecordingModel *recordingModel;
@property (strong, nonatomic) SendVoiceMessageModel *sendVoiceMessageModel;

@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *progressContainerView;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *m13ProgressViewPie;
@property (weak, nonatomic) IBOutlet UIImageView *progressCenterImageView;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (nonatomic)   NSTimeInterval totalSeconds;

+(FastRecordingView*) createInstanceWithDelegate:(UIViewController<FastRecordingViewDelegate>*) delegate;

-(void) presentWithAnimation;
-(void) finishRecordingWithGestureIsValid:(BOOL) isGestureValid;

@end
