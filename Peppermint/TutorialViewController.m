//
//  TutorialViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "TutorialViewController.h"
#import "Repository.h"
#import "ReSideMenuContainerViewController.h"
#import "ContactsViewController.h"

#define SEGUE_CONTACTS_VIEW_CONTROLLER  @"ContactsViewControllerSegue"
#define TAG_IMAGE_VIEW                  1
#define DURATION                        0.3

@interface TutorialViewController ()

@end

@implementation TutorialViewController {
    ContactsModel* contactsModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    contactsModel = nil;
    self.items = [NSArray arrayWithObjects:@"tutorial1",@"tutorial2",@"tutorial3",@"_NEXPAGE_", nil];
    [self initContinueButton];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self checkIfuserIsLoggedIn]) {
        [self askUserForContactsReadPermission];
        [self performSelector:@selector(page1ButtonPressed:) withObject:nil afterDelay:DURATION/3];
    }    
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self page1ButtonPressed:nil];
}

-(void) askUserForContactsReadPermission {
    contactsModel = [ContactsModel sharedInstance];
    contactsModel.delegate = self;
    [contactsModel setup];
}

#pragma mark - SwipeView Delegate

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return self.items.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    NSInteger lastItemIndex = self.items.count - 1;
    if(index == lastItemIndex) {
        [self finishTutorial];
    }
    
    UIImageView *imageView = nil;
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        imageView = [[UIImageView alloc] initWithFrame:view.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        imageView.backgroundColor = [UIColor clearColor];
        imageView.tag = TAG_IMAGE_VIEW;
        [view addSubview:imageView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = view.bounds;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(imageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    else
    {
        imageView = (UIImageView *)[view viewWithTag:TAG_IMAGE_VIEW];
    }
    imageView.image = [UIImage imageNamed:[self.items objectAtIndex:index]];
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}

- (void)swipeViewDidScroll:(SwipeView *)swipeView {
    [self.page1Button setSelected:(swipeView.currentItemIndex == 0)];
    [self.page2Button setSelected:(swipeView.currentItemIndex == 1)];
    [self.page3Button setSelected:(swipeView.currentItemIndex == 2)];
    
    CGFloat newAlpha = (swipeView.currentItemIndex != 2) ? 0 : 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.continueButton.alpha = newAlpha;
    }];
}

#pragma mark - Button Actions

-(IBAction)page1ButtonPressed:(id)sender {
    [self.swipeView scrollToPage:0 duration:DURATION];
}

-(IBAction)page2ButtonPressed:(id)sender {
    [self.swipeView scrollToPage:1 duration:DURATION];
}

-(IBAction)page3ButtonPressed:(id)sender {
    [self.swipeView scrollToPage:2 duration:DURATION];
}

-(void) imageButtonTapped {
    [self.swipeView scrollByNumberOfItems:1 duration:DURATION];
}

#pragma mark - ContactsModelDelegate

-(void) contactsAccessRightsAreNotSupplied {
    NSString *title = LOC(@"Information", @"Title Message");
    NSString *message = LOC(@"Contacts access rights explanation", @"Directives to give access rights");
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    NSString *settingsButtonTitle = LOC(@"Settings", @"Settings Message");
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:settingsButtonTitle, nil] show];
}

-(void) contactListRefreshed {
    //No need to implement.
}

#pragma mark - Continue Button

-(void) initContinueButton {
    [self.continueButton.titleLabel setFont:[UIFont openSansSemiBoldFontOfSize:16]];
    [self.continueButton setTitle:LOC(@"Continue", @"Continue") forState:UIControlStateNormal];
    [self.continueButton setTitleColor:[UIColor continueButtonTitle] forState:UIControlStateNormal];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self continueButtonReleased:nil];
    self.continueButton.alpha = 0;
    
    self.continueButton.layer.cornerRadius = CONTINUE_BUTTON_CORNER_RADIUS;
    self.continueButton.layer.shadowOffset = CGSizeMake(0, 3);
    self.continueButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.continueButton.layer.shadowOpacity = 0.1;
    self.continueButton.layer.shadowRadius = 1;
}

-(IBAction)continueButtonDown:(id)sender {
    self.continueButton.backgroundColor = [UIColor blackColor];
}

-(IBAction)continueButtonReleased:(id)sender {
    self.continueButton.backgroundColor = [UIColor whiteColor];
}

-(IBAction)continueButtonPressed:(id)sender {
    [self continueButtonReleased:sender];
    [self finishTutorial];
}

#pragma mark - FinishTutorial

-(void) finishTutorial {
    defaults_set_object(DEFAULTS_KEY_ISTUTORIALSHOWED, @(YES));
    [self performSegueWithIdentifier:SEGUE_CONTACTS_VIEW_CONTROLLER sender:self];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if([alertView.message isEqualToString:LOC(@"Contacts access rights explanation", @"Directives to give access rights")]) {
        switch (buttonIndex) {
            case ALERT_BUTTON_INDEX_OTHER_1:
                [self redirectToSettingsPageForPermission];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_CONTACTS_VIEW_CONTROLLER]) {
        ReSideMenuContainerViewController *reSideMenuContainerViewController = (ReSideMenuContainerViewController*) segue.destinationViewController;
        [reSideMenuContainerViewController initContactsViewControllerWithContactsModel:contactsModel];
    }
}

@end
