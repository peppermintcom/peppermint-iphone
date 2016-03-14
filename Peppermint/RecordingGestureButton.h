//
//  RecordingGestureButton.h
//  Peppermint
//
//  Created by Okan Kurtulus on 23/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordingGestureButtonDelegate <NSObject>
-(void) touchDownBeginOnIndexPath:(id) sender event:(UIEvent *)event;
-(void) touchHoldSuccessOnLocation:(CGPoint) touchBeginPoint;
-(void) touchSwipeActionOccuredOnLocation:(CGPoint) location;
-(void) touchShortTapActionOccuredOnLocation:(CGPoint) location;
-(void) touchCompletedAsExpectedWithSuccessOnLocation:(CGPoint) location;
-(void) touchDownCancelledWithEvent:(UIEvent *)event location:(CGPoint)location;
@end

@interface RecordingGestureButton : UIButton
@property (weak, nonatomic) id<RecordingGestureButtonDelegate> delegate;
@end