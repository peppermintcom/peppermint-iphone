//
//  HoldToRecordInfoView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 30/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "HoldToRecordInfoView.h"

#define HOLDTORECORDVIEW_DURATION   1

@implementation HoldToRecordInfoView {
    NSTimer *holdToRecordViewTimer;
}

-(void) awakeFromNib {
    [super awakeFromNib];
    [self initHoldToRecordInfoView];
}

-(void) initHoldToRecordInfoView {
    holdToRecordViewTimer = nil;
    self.hidden = YES;
    if(!self.holdToRecordInfoViewLabel) {
        NSLog(@"Please bind holdToRecordInfoViewLabel to show information correctly!");
    }
    self.holdToRecordInfoViewLabel.font = [UIFont openSansSemiBoldFontOfSize:14];
    self.holdToRecordInfoViewLabel.text = LOC(@"Hold to record message",@"Hold to record message");
    
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    [self addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
}

-(void) showWithCompletionHandler:(void (^)(void))completionHandler {
    [holdToRecordViewTimer invalidate];
    self.hidden = YES;
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:ANIM_TIME animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        completionHandler();
        holdToRecordViewTimer = [NSTimer scheduledTimerWithTimeInterval:HOLDTORECORDVIEW_DURATION
                                                                 target:self
                                                               selector:@selector(hide)
                                                               userInfo:nil
                                                                repeats:NO];
    }];
}

-(void) hide {
    [holdToRecordViewTimer invalidate];
    holdToRecordViewTimer = nil;
    [UIView animateWithDuration:ANIM_TIME animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

@end
