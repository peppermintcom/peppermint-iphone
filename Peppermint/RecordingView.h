//
//  RecordingView.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseCustomView.h"
#import "SendVoiceMessageModel.h"
#import "RecordingModel.h"
#import "PlayingModel.h"
#import "RecordingGestureButton.h"

@protocol RecordingViewDelegate <SendVoiceMessageDelegate >
-(void) recordingViewDissappeared;
-(void) messageModel:(SendVoiceMessageModel*)sendVoiceMessageModel isUpdatedWithStatus:(SendingStatus) sendingStatus cancelAble:(BOOL)isCacnelAble;
@end

@interface RecordingView : BaseCustomView <RecordingModelDelegate, SendVoiceMessageDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) UIViewController<RecordingViewDelegate>* delegate;
@property (strong, nonatomic) SendVoiceMessageModel *sendVoiceMessageModel;
@property (strong, nonatomic) RecordingModel *recordingModel;
@property (strong, nonatomic) PlayingModel *playingModel;
@property (assign, nonatomic) NSTimeInterval totalSeconds;
@property (assign, nonatomic) int currentMinutes;
@property (assign, nonatomic) int currentSeconds;

+(RecordingView*) createInstanceWithDelegate:(UIViewController<RecordingViewDelegate>*) delegate;

-(BOOL) presentWithAnimationInRect:(CGRect)rect onPoint:(CGPoint) point;
-(BOOL) finishRecordingWithGestureIsValid:(BOOL) isGestureValid needsPause:(BOOL)needsPause;
-(void) cancelMessageSending;
-(void) recordingViewIsHidden;
-(void) pause;
-(void) stop;

SUBSCRIBE(MessageSendingStatusIsUpdated);
SUBSCRIBE(AudioSessionInterruptionOccured);
SUBSCRIBE(ApplicationWillResignActive);
SUBSCRIBE(ApplicationDidBecomeActive);

@end
