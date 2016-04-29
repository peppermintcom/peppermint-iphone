//
//  BaseReSideMenuContentViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 29/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseReSideMenuContentViewController.h"

@implementation BaseReSideMenuContentViewController : BaseViewController

#pragma mark - Slide Menu

-(IBAction)slideMenuTouchDown:(id)sender {
    UIButton *menuButton = (UIButton*)sender;
    menuButton.alpha = 0.7;
}

-(IBAction)slideMenuTouchUp:(id)sender {
    UIButton *menuButton = (UIButton*)sender;
    menuButton.alpha = 1;
}

-(IBAction)slideMenuValidAction:(id)sender {
    [self slideMenuTouchUp:sender];
    [self.reSideMenuContainerViewController presentLeftMenuViewController];
}

@end
