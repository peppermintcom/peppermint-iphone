//
//  TutorialViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "SwipeView.h"

@interface TutorialViewController : BaseViewController <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, weak) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, weak) IBOutlet UIButton *page1Button;
@property (nonatomic, weak) IBOutlet UIButton *page2Button;
@property (nonatomic, weak) IBOutlet UIButton *page3Button;

-(IBAction)page1ButtonPressed:(id)sender;
-(IBAction)page2ButtonPressed:(id)sender;
-(IBAction)page3ButtonPressed:(id)sender;

@end
