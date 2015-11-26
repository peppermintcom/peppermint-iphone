//
//  UIView+Addition.h
//  Peppermint
//
//  Created by Yan Saraev on 11/24/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Addition)

- (void)pinSubview:(UIView *)subview
            toEdge:(NSLayoutAttribute)attribute;

- (void)pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute constant:(CGFloat)constant;


- (void)pinWidthOfSubview:(UIView *)subview;

- (void)pinHeightOfSubview:(UIView *)subview;

- (void)pinAllEdgesOfSubview:(UIView *)subview;

- (void)pinAllEdgesOfSubview:(UIView *)subview
                   toSubview:(UIView *)secondSubview;

- (void)pinSubview:(UIView *)subview
         toSubview:(UIView *)secondSubview
            toEdge:(NSLayoutAttribute)attribute;

- (void)pinEdge:(NSLayoutAttribute)edge
        subview:(UIView *)subview
         toView:(UIView *)view
           edge:(NSLayoutAttribute)secondEdge;

- (void)pinRelationWidth:(CGFloat)relation
               ofSubview:(UIView *)subview;

- (void)setHeight:(CGFloat)height
        ofSubview:(UIView *)subview;

@end
