//
//  FoggyRecordingView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "FoggyRecordingView.h"
#import "ExplodingView.h"

#define IMPACT_MAX_LIMIT            48
#define IMPACT_MIN_LIMIT            0

#define SWIPE_VIEW_BOTTOM_CONSTANT  5

@implementation FoggyRecordingView {
    CGRect originalMicrophoneFrame;
    CGFloat previousImpact;
}

+(FoggyRecordingView*) createInstanceWithDelegate:(UIViewController<RecordingViewDelegate>*) delegate {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FoggyRecordingView"
                                                             owner:self
                                                           options:nil];
    FoggyRecordingView *foggyRecordingView = (FoggyRecordingView *)[topLevelObjects objectAtIndex:0];
    foggyRecordingView.delegate = delegate;
    [foggyRecordingView timerUpdated:0];
    foggyRecordingView.playingModel = [PlayingModel new];
    return foggyRecordingView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setGestureRecognisers];
    
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.alpha = 0.3;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.rowView.backgroundColor = [UIColor whiteColor];
    
    self.rowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.rowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.rowView.layer.shadowOpacity = 0.5;
    self.rowView.layer.shadowRadius = 10;
    
    self.informationLabel.textColor = [UIColor blackColor];
    self.informationLabel.font = [UIFont openSansSemiBoldFontOfSize:14];
    self.counterLabel.textColor = [UIColor blackColor];
    self.counterLabel.font = [UIFont openSansBoldFontOfSize:21];
    
    self.swipeInAnyDirectionLabel.textColor = [UIColor emptyResultTableViewCellHeaderLabelTextcolorGray];
    self.swipeInAnyDirectionLabel.font = [UIFont openSansSemiBoldFontOfSize:15];
    self.swipeInAnyDirectionLabel.text = LOC(@"Swipe anywhere to cancel", @"Information");
    
}

#pragma mark - FoggyRecordingView User Interaction

-(void) setGestureRecognisers {
    self.gestureRecognizers = [NSArray arrayWithObjects:
                               [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)],
                               [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped)]
                               , nil];
}

-(void) tapped {
    [self finishRecordingWithGestureIsValid:YES];
}

-(void) swiped {
    [self finishRecordingWithGestureIsValid:NO];
}

#pragma mark - Record Methods

-(BOOL) presentWithAnimationInRect:(CGRect)rect onPoint:(CGPoint) point {
    BOOL result = [super presentWithAnimationInRect:rect onPoint:point];
    if(result) {
        self.contentViewYOffset.constant = rect.origin.y - self.RowViewYOffset.constant;
        self.swipeInAnyDirectionViewBottomConstraint.constant = SWIPE_VIEW_BOTTOM_CONSTANT;
        self.swipeBackGroundImageView.image = [UIImage imageNamed:@"base_down"];
        self.swipeBackGroundImageViewTopConstraint.constant = 0;
        if(self.contentViewYOffset.constant <= self.swipeInAnyDirectionView.frame.size.height / 2) {
            self.swipeInAnyDirectionViewBottomConstraint.constant =
            -self.rowView.frame.size.height
            -2 * self.swipeInAnyDirectionViewBottomConstraint.constant
            -self.swipeInAnyDirectionView.frame.size.height;
            
            
            UIImage *sourceImage = self.swipeBackGroundImageView.image;
            UIImage* flippedImage = [UIImage imageWithCGImage:sourceImage.CGImage
                                                        scale:sourceImage.scale
                                                  orientation:UIImageOrientationDownMirrored];
            self.swipeBackGroundImageView.image = flippedImage;
            self.swipeBackGroundImageViewTopConstraint.constant = -2*SWIPE_VIEW_BOTTOM_CONSTANT;
        }
        
        
        self.counterLabel.text = @"";
        self.informationLabel.text = [NSString stringWithFormat:
                                          LOC(@"Recording for contact format", @"Title Text Format"),
                                          self.sendVoiceMessageModel.selectedPeppermintContact.nameSurname,
                                          self.sendVoiceMessageModel.selectedPeppermintContact.communicationChannelAddress
                                          ];
        [self show];
    }
    return result;
}

-(BOOL) finishRecordingWithGestureIsValid:(BOOL) isGestureValid {
    BOOL isRecordingShort = self.totalSeconds <= MIN_VOICE_MESSAGE_LENGTH;
    if(isGestureValid && isRecordingShort) {
        CGRect frame = CGRectMake(
                                  originalMicrophoneFrame.origin.x + originalMicrophoneFrame.size.width / 2,
                                  originalMicrophoneFrame.origin.y + originalMicrophoneFrame.size.height / 2,
                                  0,
                                  0);
        [UIView animateWithDuration:0.2 animations:^{
            self.microphoneImageView.frame = frame;
        } completion:^(BOOL finished) {
            self.microphoneImageView.hidden = YES;
            self.microphoneImageView.frame = originalMicrophoneFrame;
        }];
    }
    return [super finishRecordingWithGestureIsValid:isGestureValid];
}

#pragma mark - Show

-(void) show {
    self.microphoneImageView.hidden = NO;
    CGRect originalRowViewFrame = self.rowView.frame;
    originalMicrophoneFrame = self.microphoneImageView.frame;
    
    CGRect rowViewFrame = self.rowView.frame;
    rowViewFrame.origin.x = rowViewFrame.size.width * -1;
    self.rowView.frame = rowViewFrame;
    
    CGRect microphoneFrame = self.microphoneImageView.frame;
    microphoneFrame.origin.x += microphoneFrame.size.width / 2;
    microphoneFrame.origin.y += microphoneFrame.size.height / 2;
    microphoneFrame.size.width = microphoneFrame.size.height = 0;
    self.microphoneImageView.frame = microphoneFrame;
    self.rowView.alpha = 0;
    self.swipeInAnyDirectionLabel.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.rowView.frame = originalRowViewFrame;
        self.rowView.alpha = 1;
        self.microphoneImageView.frame = originalMicrophoneFrame;
        self.swipeInAnyDirectionLabel.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Dissmiss

-(void) dissmissWithFadeOut {
    CGRect originalRowViewFrame = self.rowView.frame;
    CGRect rowViewFrame = self.rowView.frame;
    rowViewFrame.origin.x += rowViewFrame.size.width;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.rowView.frame = rowViewFrame;
        self.microphoneImageView.frame = originalMicrophoneFrame;
    } completion:^(BOOL completed) {
        self.hidden = YES;
        self.rowView.frame = originalRowViewFrame;
        self.microphoneImageView.frame = originalMicrophoneFrame;
        self.alpha = 1;
        [self timerUpdated:0];
        [self recordingViewIsHidden];
    }];
}

-(void) dissmissWithExplode {
    ExplodingView *explodingView = [ExplodingView createInstanceFromView:self.microphoneImageView];
    explodingView.piecesMultiplier = 0.4;
    [self.contentView addSubview:explodingView];
    [self.contentView bringSubviewToFront:explodingView];
    self.microphoneImageView.hidden = YES;
    [explodingView lp_explodeWithCallback:^{
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
        } completion:^(BOOL completed) {
            self.hidden = YES;
            self.microphoneImageView.frame = originalMicrophoneFrame;
            self.alpha = 1;
            [self timerUpdated:0];
            [self recordingViewIsHidden];
        }];
    }];
}

#pragma mark - RecordingModel Delegate

-(void) timerUpdated:(NSTimeInterval) timeInterval {
    [super timerUpdated:timeInterval];
    if(self.totalSeconds <= MAX_RECORD_TIME) {
        self.counterLabel.text = [NSString stringWithFormat:@"%.1d:%.2d", self.currentMinutes, self.currentSeconds];
    }
}

-(void) meteringUpdatedWithAverage:(CGFloat)average andPeak:(CGFloat)peak {
    if(self.totalSeconds < 0.1) {
        originalMicrophoneFrame = self.microphoneImageView.frame;
        previousImpact = 0;
    } else {
        int referenceLevel = 5;
        int range = 160;
        int offset = 0;
        CGFloat impact = 20 * log10(referenceLevel * powf(10, (average/20)) * range) + offset;
        impact = impact *  IMPACT_MAX_LIMIT/80;
        
        impact = (impact > IMPACT_MAX_LIMIT) ? IMPACT_MAX_LIMIT : impact;
        impact = (impact < IMPACT_MIN_LIMIT) ? IMPACT_MIN_LIMIT : impact;
        CGRect frame =  CGRectMake(originalMicrophoneFrame.origin.x,
                                   originalMicrophoneFrame.origin.y,
                                   originalMicrophoneFrame.size.width,
                                   originalMicrophoneFrame.size.height);
        frame.size.height += impact;
        frame.size.width  += impact;
        frame.origin.x -= impact/2;
        frame.origin.y -= impact/2;
        
        previousImpact = (previousImpact == 0) ? impact : previousImpact;
        CGFloat diff = fabs(impact - previousImpact);
        if(previousImpact ==0 || diff > (IMPACT_MAX_LIMIT / 16)) {
            self.microphoneImageView.frame = frame;
            previousImpact = impact;
        }
    }
}

#warning "Find a better way to handle subscribe, cos this method is possible to be forgotten in subclass implementations!"

SUBSCRIBE(MessageSendingStatusIsUpdated) {
    [super onMessageSendingStatusIsUpdated:event];
}

SUBSCRIBE(ApplicationWillResignActive) {
    [super onApplicationWillResignActive:event];
}

SUBSCRIBE(ApplicationDidBecomeActive) {
    [super onApplicationDidBecomeActive:event];
}

@end
