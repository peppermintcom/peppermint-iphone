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
#import "LoginNavigationViewController.h"
#import "PlayingModel.h"

@protocol FastRecordingViewDelegate <SendVoiceMessageDelegate>
-(void) fastRecordingViewDissappeared;
-(void) message:(NSString*) message isUpdatedWithStatus:(SendingStatus) sendingStatus cancelAble:(BOOL)isCacnelAble;
@end

@interface FastRecordingView : BaseCustomView <RecordingModelDelegate, SendVoiceMessageDelegate, UIAlertViewDelegate, LoginNavigationViewControllerDelegate>
@property (weak, nonatomic) UIViewController<FastRecordingViewDelegate>* delegate;
@property (strong, nonatomic) RecordingModel *recordingModel;
@property (strong, nonatomic) SendVoiceMessageModel *sendVoiceMessageModel;
@property (strong, nonatomic) PlayingModel *playingModel;

@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *progressContainerView;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *m13ProgressViewPie;
@property (weak, nonatomic) IBOutlet UIImageView *progressCenterImageView;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (nonatomic)   NSTimeInterval totalSeconds;
@property (weak, nonatomic) IBOutlet UILabel *swipeInAnyDirectionLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

+(FastRecordingView*) createInstanceWithDelegate:(UIViewController<FastRecordingViewDelegate>*) delegate;

-(void) presentWithAnimation;
-(void) finishRecordingWithGestureIsValid:(BOOL) isGestureValid;
-(void) cancelMessageSending;

@end
