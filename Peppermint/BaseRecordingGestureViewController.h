//
//  BaseRecordingGestureViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 05/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseRecordingViewController.h"

@interface BaseRecordingGestureViewController : BaseRecordingViewController
@property (strong, nonatomic) RecordingView *_recordingView;

#pragma mark - Recording Gesture
SUBSCRIBE(ProximitySensorValueIsUpdated);
SUBSCRIBE(ShakeGestureOccured);
-(void) recordingIsTriggeredWithGesture;
-(void) cancelSending;

@end
