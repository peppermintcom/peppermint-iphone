//
//  TutorialViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 27/09/15.
//  Copyright (c) 2015 Okan Kurtulus. All rights reserved.
//

#import "TutorialViewController.h"
#import "Repository.h"
#import "ContactsViewController.h"

#define SEGUE_CONTACTS_VIEW_CONTROLLER  @"ContactsViewControllerSegue"
#define TAG_IMAGE_VIEW                  1
#define DURATION                        0.3

@interface TutorialViewController ()

@end

@implementation TutorialViewController {
    UIAlertView *contactsAlertView;
    ContactsModel* contactsModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    contactsAlertView = nil;
    contactsModel = nil;
    self.items = [NSArray arrayWithObjects:@"tutorial1",@"tutorial2",@"tutorial3",@"_NEXPAGE_", nil];
    self.swipeView.backgroundColor = [UIColor tutorialGreen];
    [self askUserForContactsReadPermission];
}

-(void) askUserForContactsReadPermission {
    contactsModel = [ContactsModel new];
    contactsModel.delegate = self;
    [contactsModel setup];
}

#pragma mark - SwipeView Delegate

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return self.items.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if(index == self.items.count -1) {
        [self performSegueWithIdentifier:SEGUE_CONTACTS_VIEW_CONTROLLER sender:self];
    }
    
    UIImageView *imageView = nil;
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        imageView = [[UIImageView alloc] initWithFrame:view.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
    NSString *message = LOC(@"Contacts access rights explanation", @"Directives to give access rights") ;
    NSString *cancelButtonTitle = LOC(@"Ok", @"Ok Message");
    NSString *settingsButtonTitle = LOC(@"Settings", @"Settings Message");
    contactsAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:settingsButtonTitle, nil];
    [contactsAlertView show];
}

-(void) contactListRefreshed {
    //No need to implement.
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView == contactsAlertView) {
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
        ContactsViewController *contactsViewController = (ContactsViewController*) segue.destinationViewController;
        contactsViewController.contactsModel = contactsModel;
        contactsViewController.contactsModel.delegate = contactsViewController;
    }
}

@end
