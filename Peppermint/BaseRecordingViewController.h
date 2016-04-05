//
//  BaseRecordingViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 05/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "RecordingView.h"

@interface BaseRecordingViewController : BaseViewController <RecordingViewDelegate>
@property (strong, nonatomic) RecordingView *_recordingView;
@end
