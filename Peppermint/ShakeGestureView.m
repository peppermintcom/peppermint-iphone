//
//  ShakeGestureView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 16/03/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "ShakeGestureView.h"

@implementation ShakeGestureView

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        NSLog(@"Shaking occuring..");
        ShakeGestureOccured *shakeGestureOccured = [ShakeGestureOccured new];
        shakeGestureOccured.sender = self;
        PUBLISH(shakeGestureOccured);
    }
    
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
