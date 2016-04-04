//
//  ReSideMenuContainerViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "ReSideMenuContainerViewController.h"
#import "SlideMenuViewController.h"
#import "ContactsViewController.h"

@interface ReSideMenuContainerViewController ()

@end

@implementation ReSideMenuContainerViewController

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initSlideMenu];
        REGISTER();
    }
    return self;
}

SUBSCRIBE(ApplicationDidBecomeActive) {
    [self hideMenuViewController];
}

#pragma mark - SlidingMenu

-(void) initSlideMenu {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:nil];
    ContactsViewController *contactsVC = (ContactsViewController*)[storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_CONTACTS];
    SlideMenuViewController *slideMenuVC = (SlideMenuViewController*)[storyboard instantiateViewControllerWithIdentifier: VIEWCONTROLLER_SLIDEMENU];
    
    contactsVC.reSideMenuContainerViewController = self;
    slideMenuVC.reSideMenuContainerViewController = self;
    self.delegate = slideMenuVC;
    [self setLeftMenuViewController:slideMenuVC];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactsVC];
    [self setContentViewController:navigationController];
    
    
    self.interactivePopGestureRecognizerEnabled = YES;
    self.fadeMenuView = YES;
    self.scaleContentView = NO;
    self.scaleBackgroundImageView = NO;
    self.scaleMenuView = NO;
    self.contentViewShadowEnabled = YES;
    
}

#pragma mark - InitContactsViewController

-(void) initContactsViewControllerWithContactsModel:(ContactsModel*) contactsModel {    
    UINavigationController *navigationController = (UINavigationController*) self.contentViewController;
    ContactsViewController *contactsViewController = (ContactsViewController*) [navigationController.viewControllers objectAtIndex:0];
    if(!contactsViewController.contactsModel) {
        contactsViewController.contactsModel = contactsModel;
    } else {
        NSLog(@"Contacts model already exists");
    }
    contactsViewController.contactsModel.delegate = contactsViewController;
}

@end
