//
//  FoggyRecordingView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/12/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "FoggyRecordingView.h"
#import "ExplodingView.h"

#define IMPACT_LIMIT        16

@implementation FoggyRecordingView {
    CGRect baseMicrophoneFrame;
    int baseVoiceLevel;
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
    
    self.microphoneImageView.layer.cornerRadius = 36;
    
    self.swipeInAnyDirectionLabel.textColor = [UIColor emptyResultTableViewCellHeaderLabelTextcolorGray];
    self.swipeInAnyDirectionLabel.font = [UIFont openSansSemiBoldFontOfSize:15];
    self.swipeInAnyDirectionLabel.text = LOC(@"Swipe anywhere to cancel", @"Swipe anywhere to cancel label");
    
    baseVoiceLevel = 0;
}

#pragma mark - FastRecordingView User Interaction

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
        self.contentViewYOffset.constant = rect.origin.y + self.RowViewYOffset.constant + 2;
        baseVoiceLevel = 0;
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

#pragma mark - Show

-(void) show {
    self.microphoneImageView.hidden = NO;
    CGRect originalRowViewFrame = self.rowView.frame;
    CGRect originalMicrophoneFrame = self.microphoneImageView.frame;
    
    CGRect rowViewFrame = self.rowView.frame;
    rowViewFrame.origin.x = rowViewFrame.size.width * -1;
    self.rowView.frame = rowViewFrame;
    
    CGRect microphoneFrame = self.microphoneImageView.frame;
    microphoneFrame.origin.x += microphoneFrame.size.width / 2;
    microphoneFrame.origin.y += microphoneFrame.size.height / 2;
    microphoneFrame.size.width = microphoneFrame.size.height = 0;
    self.microphoneImageView.frame = microphoneFrame;
    
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        self.rowView.frame = originalRowViewFrame;
        self.microphoneImageView.frame = originalMicrophoneFrame;
    }];
}

#pragma mark - Dissmiss

-(void) dissmissWithFadeOut {
    CGRect originalRowViewFrame = self.rowView.frame;
    CGRect rowViewFrame = self.rowView.frame;
    rowViewFrame.origin.x += rowViewFrame.size.width;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.rowView.frame = rowViewFrame;
    } completion:^(BOOL completed) {
        self.hidden = YES;
        self.rowView.frame = originalRowViewFrame;
        self.alpha = 1;
        [self timerUpdated:0];
        [self recordingViewIsHidden];
    }];
}

-(void) dissmissWithExplode {
    ExplodingView *explodingView = [ExplodingView createInstanceFromView:self.microphoneImageView];
    [self.contentView addSubview:explodingView];
    [self.contentView bringSubviewToFront:explodingView];
    self.microphoneImageView.hidden = YES;
    [explodingView lp_explodeWithCallback:^{
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
        } completion:^(BOOL completed) {
            self.hidden = YES;
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
    if(baseVoiceLevel == 0 && average > -100) {
        baseVoiceLevel = -average;
        baseMicrophoneFrame = self.microphoneImageView.frame;
    } else if (baseVoiceLevel > 1) {        
        CGFloat impact = (int)(baseVoiceLevel + average);
        impact = (impact > IMPACT_LIMIT) ? IMPACT_LIMIT : impact;
        CGRect frame =  CGRectMake(baseMicrophoneFrame.origin.x,
                                   baseMicrophoneFrame.origin.y,
                                   baseMicrophoneFrame.size.width,
                                   baseMicrophoneFrame.size.height);
        frame.size.height += impact;
        frame.size.width  += impact;
        frame.origin.x -= impact/2;
        frame.origin.y -= impact/2;
        self.microphoneImageView.frame = frame;
        self.microphoneImageView.layer.cornerRadius = frame.size.height / 2;
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
