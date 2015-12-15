//
//  FoggyRecordingView.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "RecordingView.h"

@interface FoggyRecordingView : RecordingView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewYOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *RowViewYOffset;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *rowView;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *microphoneImageView;
@property (weak, nonatomic) IBOutlet UILabel *swipeInAnyDirectionLabel;

@end
