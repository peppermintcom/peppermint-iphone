//
//  UIViewController_AdditionViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 13/10/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "UIViewController_AdditionViewController.h"


@implementation UIViewController (UIViewController_AdditionViewController)

- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

@end
