//
//  ContactTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "ContactTableViewCell.h"

#define EVENT                   @"Event"
#define HOLD_LIMIT              0.05
#define SWIPE_SPEED_LIMIT       20

@implementation ContactTableViewCell {
    CGPoint touchBeginPoint;
    NSTimer *timer;
    UIView *rootView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.layer.borderColor  = [UIColor whiteColor].CGColor;
    self.cellSeperatorView.backgroundColor = [UIColor cellSeperatorGray];
    self.contactNameLabel.font = [UIFont openSansSemiBoldFontOfSize:17];
    self.contactViaCaptionLabel.font = [UIFont openSansSemiBoldFontOfSize:13];
    self.contactViaInformationLabel.font = [UIFont openSansSemiBoldFontOfSize:13];
    self.contactViaCaptionLabel.text = LOC(@"via", @"Localized value for the word via");
    [self applyNonSelectedStyle];
    timer = nil;
    rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected) {
        [self applySelectedStyle];
    } else {
        [self applyNonSelectedStyle];
    }
}

-(void) applySelectedStyle {
    self.backgroundColor = [UIColor peppermintGreen];
    self.avatarImageView.layer.borderWidth = 2;
    self.contactNameLabel.textColor = [UIColor whiteColor];
    self.contactViaCaptionLabel.textColor = [UIColor whiteColor];
    self.contactViaInformationLabel.textColor = [UIColor whiteColor];
}

-(void) applyNonSelectedStyle {
    self.backgroundColor = [UIColor whiteColor];
    self.avatarImageView.layer.borderWidth = 0;
    self.contactNameLabel.textColor = [UIColor blackColor];
    self.contactViaCaptionLabel.textColor = [UIColor textFieldTintGreen];
    self.contactViaInformationLabel.textColor = [UIColor viaInformationLabelTextGreen];
}

#pragma mark - Action Buttons

-(IBAction) touchDownOnIndexPath:(id) sender event:(UIEvent *)event {
    [self applySelectedStyle];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:event forKey:EVENT];
    touchBeginPoint = CGPointMake(0, 0);
    timer = [NSTimer scheduledTimerWithTimeInterval:HOLD_LIMIT target:self selector:@selector(touchingHold) userInfo:userInfo repeats:NO];
}

-(void) touchingHold {
    UIEvent *event = [timer.userInfo valueForKey:EVENT];
    [timer invalidate];
    UITouch *touch = [[event allTouches] anyObject];
    touchBeginPoint = [touch locationInView:rootView];
    [self.delegate didBeginItemSelectionOnIndexpath:self.indexPath location:touchBeginPoint];
}

-(IBAction) touchDragging:(id)sender event:(UIEvent *)event {
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
        
        if(!speedIsInLimit
           || bounds.origin.x >= location.x
           || bounds.origin.y >= location.y
           || bounds.size.width <= location.x
           || bounds.size.height <= location.y
           ) {
            if(timer.isValid)
               [timer invalidate];
            timer = nil;
            [self applyNonSelectedStyle];
            [self.delegate didCancelItemSelectionOnIndexpath:self.indexPath location:touchBeginPoint];
        }
    }
}

-(IBAction) touchDownFinishedOnIndexPath:(id) sender event:(UIEvent *)event {
    if(timer) {
        [self applyNonSelectedStyle];
        if(timer.isValid)  {
            [timer invalidate];
            timer = nil;
            
            UITouch *touch = [[event allTouches] anyObject];
            CGPoint endPoint = [touch locationInView:rootView];
            [self.delegate didShortTouchOnIndexPath:self.indexPath location:endPoint];
        } else {
            timer = nil;
            [self.delegate didFinishItemSelectionOnIndexPath:self.indexPath location:touchBeginPoint];
        }
    }
}

@end
