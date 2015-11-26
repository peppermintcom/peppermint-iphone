//
//  BaseButton.m
//  Peppermint
//
//  Created by Yan Saraev on 11/24/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseButton.h"

@implementation BaseButton


- (void)awakeFromNib {
  if (self.ppm_highlightImage) {
    self.ppm_highlightOverlay = [[UIImageView alloc] initWithImage:self.ppm_highlightImage];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.ppm_highlightOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    self.ppm_highlightOverlay.contentMode = UIViewContentModeRedraw;
    self.ppm_highlightOverlay.hidden = YES;
    [self addSubview:self.ppm_highlightOverlay];
    [self pinAllEdgesOfSubview:self.ppm_highlightOverlay];
  }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
  if (self.ppm_highlightOverlay) {
    self.ppm_highlightOverlay.hidden = !highlighted;
    [self bringSubviewToFront:self.ppm_highlightOverlay];
  } else {
    [super setHighlighted:highlighted];
  }
}


@end
