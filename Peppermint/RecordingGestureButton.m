//
//  RecordingGestureButton.m
//  Peppermint
//
//  Created by Okan Kurtulus on 23/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "RecordingGestureButton.h"

#define EVENT                   @"Event"
#define HOLD_LIMIT              0.050
#define SWIPE_SPEED_LIMIT       20

@implementation RecordingGestureButton {
    CGPoint touchBeginPoint;
    NSTimer *timer;
    UIView *rootView;
    BOOL isCellAvailableToHaveUserInteraction;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    timer = nil;
    rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    isCellAvailableToHaveUserInteraction = YES;
    
    [self addTarget:self action:@selector(touchDownCancelled:event:)    forControlEvents:UIControlEventTouchCancel];
    [self addTarget:self action:@selector(touchDown:event:)             forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchDragging:event:)         forControlEvents:UIControlEventTouchDragInside];
    [self addTarget:self action:@selector(touchDragging:event:)         forControlEvents:UIControlEventTouchDragOutside];
    [self addTarget:self action:@selector(touchDownFinished:event:)     forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchDownFinished:event:)     forControlEvents:UIControlEventTouchUpOutside];
}

#pragma mark - Action Buttons

-(void) touchDown:(id) sender event:(UIEvent *)event {
    if(isCellAvailableToHaveUserInteraction) {
        isCellAvailableToHaveUserInteraction = NO;
        [self.delegate touchDownBeginOnIndexPath:sender event:event];
        touchBeginPoint = CGPointMake(0, 0);
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:event forKey:EVENT];
        timer = [NSTimer scheduledTimerWithTimeInterval:HOLD_LIMIT target:self selector:@selector(touchingHold) userInfo:userInfo repeats:NO];
    }
}

-(void) touchingHold {
    if(!isCellAvailableToHaveUserInteraction) {
        UIEvent *event = [timer.userInfo valueForKey:EVENT];
        [timer invalidate];
        UITouch *touch = [[event allTouches] anyObject];
        touchBeginPoint = [touch locationInView:rootView];
        [self.delegate touchHoldSuccessOnLocation:touchBeginPoint];
    }
}

-(void) touchDragging:(id)sender event:(UIEvent *)event {
    if(timer) {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:rootView];
        CGRect bounds = UIScreen.mainScreen.bounds;
        
        BOOL speedIsInLimit = YES;
        if(touchBeginPoint.x != 0 || touchBeginPoint.y != 0) {
            CGFloat xDist = (location.x - touchBeginPoint.x);
            CGFloat yDist = (location.y - touchBeginPoint.y);
            CGFloat speed = sqrt((xDist * xDist) + (yDist * yDist));
            touchBeginPoint = location;
            speedIsInLimit = speed <= SWIPE_SPEED_LIMIT;
        }
        
        BOOL isOutOfBounds = bounds.origin.x >= location.x || bounds.origin.y >= location.y
        || bounds.size.width <= location.x || bounds.size.height <= location.y;
        
        if(!isCellAvailableToHaveUserInteraction && (!speedIsInLimit || isOutOfBounds)) {
            if(timer.isValid)
                [timer invalidate];
            timer = nil;
            isCellAvailableToHaveUserInteraction = YES;
            [self.delegate touchSwipeActionOccuredOnLocation:touchBeginPoint];
        }
    }
}

-(void) touchDownFinished:(id) sender event:(UIEvent *)event {
    if(!isCellAvailableToHaveUserInteraction) {
        isCellAvailableToHaveUserInteraction = YES;
        if(timer != nil) {
            if(timer.isValid)  {
                [timer invalidate];
                timer = nil;
                UITouch *touch = [[event allTouches] anyObject];
                CGPoint endPoint = [touch locationInView:rootView];
                [self.delegate touchShortTapActionOccuredOnLocation:endPoint];
            } else {
                timer = nil;
                [self.delegate touchCompletedAsExpectedWithSuccessOnLocation:touchBeginPoint];
            }
        }
    }
}

-(void) touchDownCancelled:(id) sender event:(UIEvent *)event {
    isCellAvailableToHaveUserInteraction = YES;
    [self.delegate touchDownCancelledWithEvent:event];
}

@end
