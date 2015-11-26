//
//  CountryRow.m
//  Peppermint
//
//  Created by Yan Saraev on 11/26/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "CountryRow.h"

@implementation CountryRow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
  self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
  return self;
}

@end
