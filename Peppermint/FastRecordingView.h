//
//  FastRecordingView.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordingView.h"

#import "M13ProgressViewPie.h"
#import "ExplodingView.h"
#import "LoginNavigationViewController.h"


@interface FastRecordingView : RecordingView

@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *progressContainerView;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *m13ProgressViewPie;
@property (weak, nonatomic) IBOutlet UIImageView *progressCenterImageView;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UILabel *swipeInAnyDirectionLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

SUBSCRIBE(MessageSendingStatusIsUpdated);
SUBSCRIBE(ApplicationWillResignActive);
SUBSCRIBE(ApplicationDidBecomeActive);

@end
