//
//  BaseReSideMenuContentViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 29/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ReSideMenuContainerViewController.h"

@interface BaseReSideMenuContentViewController : BaseViewController
@property (weak, nonatomic) ReSideMenuContainerViewController *reSideMenuContainerViewController;

#pragma mark - Slide Menu
-(IBAction)slideMenuTouchDown:(id)sender;
-(IBAction)slideMenuTouchUp:(id)sender;
-(IBAction)slideMenuValidAction:(id)sender;

@end
