//
//  FastRecordingView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 15/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "FastRecordingView.h"
#import "ExplodingView.h"

@implementation FastRecordingView

+(FastRecordingView*) createInstanceWithDelegate:(UIViewController<RecordingViewDelegate>*) delegate {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FastRecordingView"
                                                             owner:self
                                                           options:nil];
    FastRecordingView *fastRecordingView = (FastRecordingView *)[topLevelObjects objectAtIndex:0];
    fastRecordingView.delegate = delegate;
    [fastRecordingView timerUpdated:0];
    fastRecordingView.playingModel = [PlayingModel new];
    return fastRecordingView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setGestureRecognisers];
    self.backgroundView.alpha = 0.95;
    
    self.navigationTitleLabel.font = [UIFont openSansSemiBoldFontOfSize:24];
    self.navigationTitleLabel.textColor = [UIColor whiteColor];
    self.counterLabel.font = [UIFont openSansSemiBoldFontOfSize:40];
    self.counterLabel.textColor = [UIColor whiteColor];
    
    self.progressContainerView.backgroundColor = [UIColor progressContainerViewGray];
    self.progressContainerView.layer.cornerRadius = 35;
    [self.m13ProgressViewPie setPrimaryColor:[UIColor progressCoverViewGreen]];
    [self.m13ProgressViewPie setSecondaryColor:[UIColor clearColor]];
    
    self.swipeInAnyDirectionLabel.text = LOC(@"Swipe in any direction to cancel", @"Swipe in any direction label");
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
    BOOL result = [super presentWithAnimationInRect:(CGRect)rect onPoint:(CGPoint) point];
    if(result) {
        self.counterLabel.text = @"";
        [self show];
        self.navigationTitleLabel.text = [NSString stringWithFormat:
                                          LOC(@"Recording for contact format", @"Title Text Format"),
                                          self.sendVoiceMessageModel.selectedPeppermintContact.nameSurname,
                                          self.sendVoiceMessageModel.selectedPeppermintContact.communicationChannelAddress
                                          ];
        
        self.progressContainerView.hidden = NO;
    }
    return result;
}

#pragma mark - Show

-(void) show {
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
}

#pragma mark - Dissmiss

-(void) dissmissWithFadeOut {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL completed) {
        self.hidden = YES;
        self.alpha = 1;
        [self timerUpdated:0];
        [self recordingViewIsHidden];
    }];
}

-(void) dissmissWithExplode {    
    ExplodingView *explodingView = [ExplodingView createInstanceFromView:self.progressContainerView];
    [self.superview addSubview:explodingView];
    [self.superview bringSubviewToFront:explodingView];
    self.progressContainerView.hidden = YES;
    [explodingView lp_explodeWithCallback:^{
        [self dissmissWithFadeOut];
    }];
}

#pragma mark - RecordingModel Delegate

-(void) timerUpdated:(NSTimeInterval) timeInterval {
    [super timerUpdated:timeInterval];
    if(self.totalSeconds <= MAX_RECORD_TIME) {
        self.counterLabel.text = [NSString stringWithFormat:@"%.1d:%.2d", self.currentMinutes, self.currentSeconds];
        [self.m13ProgressViewPie setProgress:timeInterval/(MAX_RECORD_TIME + -2 * PING_INTERVAL) animated:YES];
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
