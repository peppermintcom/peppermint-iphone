//
//  UIView+Addition.m
//  Peppermint
//
//  Created by Yan Saraev on 11/24/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)

- (void)pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute {
  [self pinSubview:subview toSubview:self toEdge:attribute];
}

- (void)pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute constant:(CGFloat)constant {
  [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                   attribute:attribute
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:attribute
                                                  multiplier:1.0f
                                                    constant:constant]];
}


- (void)pinSubview:(UIView *)subview toSubview:(UIView *)secondSubview toEdge:(NSLayoutAttribute)attribute {
  [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                   attribute:attribute
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:secondSubview
                                                   attribute:attribute
                                                  multiplier:1.0f
                                                    constant:0.0f]];
}

- (void)pinWidthOfSubview:(UIView *)subview {
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:subview
                                                   attribute:NSLayoutAttributeWidth
                                                  multiplier:1.0
                                                    constant:0]];
}

- (void)pinHeightOfSubview:(UIView *)subview {
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                   attribute:NSLayoutAttributeHeight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:subview
                                                   attribute:NSLayoutAttributeHeight
                                                  multiplier:1.0
                                                    constant:0]];
}

- (void)pinRelationWidth:(CGFloat)relation ofSubview:(UIView *)subview {
  [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeWidth
                                                  multiplier:relation
                                                    constant:0]];
}

- (void)setHeight:(CGFloat)height ofSubview:(UIView *)subview {
  [self addConstraint:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
}

- (void)pinEdge:(NSLayoutAttribute)edge subview:(UIView *)subview toView:(UIView *)view edge:(NSLayoutAttribute)secondEdge {
  [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                   attribute:edge
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:view
                                                   attribute:secondEdge
                                                  multiplier:1.0f
                                                    constant:0.0f]];
}

- (void)pinAllEdgesOfSubview:(UIView *)subview toSubview:(UIView *)secondSubview {
  [self pinSubview:subview toSubview:secondSubview toEdge:NSLayoutAttributeBottom];
  [self pinSubview:subview toSubview:secondSubview toEdge:NSLayoutAttributeTop];
  [self pinSubview:subview toSubview:secondSubview toEdge:NSLayoutAttributeLeft];
  [self pinSubview:subview toSubview:secondSubview toEdge:NSLayoutAttributeTrailing];
}

- (void)pinAllEdgesOfSubview:(UIView *)subview {
  [self pinSubview:subview toEdge:NSLayoutAttributeBottom];
  [self pinSubview:subview toEdge:NSLayoutAttributeTop];
  [self pinSubview:subview toEdge:NSLayoutAttributeLeft];
  [self pinSubview:subview toEdge:NSLayoutAttributeTrailing];
}

@end
