//
//  InitialViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 05/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "InitialViewController.h"
#import "LoginModel.h"

#define TUTORIALVIEWCONTROLLER_SEGUE @"TutorialViewControllerSegue"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_gradient"]];
}

- (void) viewWillAppear:(BOOL)animated {
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender new];

    [self performSegueWithIdentifier:TUTORIALVIEWCONTROLLER_SEGUE sender:nil];
    if(peppermintMessageSender.isValid) {
        
    } else {
        NSLog(@"burda kal!...");
    }
}

@end
