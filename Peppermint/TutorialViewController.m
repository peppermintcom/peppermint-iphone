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
    [self askUserForContactsReadPermission];
        
    NSString* name = [[self newNamesFromDeviceName:UIDevice.currentDevice.name] componentsJoinedByString:@" "];
    NSLog(@"The guessed user information is = %@", name);
}

- (NSArray*) newNamesFromDeviceName: (NSString *) deviceName
{
    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:@" '’\\"];
    NSArray* words = [deviceName componentsSeparatedByCharactersInSet:characterSet];
    NSMutableArray* names = [[NSMutableArray alloc] init];
    
    bool foundShortWord = false;
    for (NSString *word in words)
    {
        if ([word length] <= 2)
            foundShortWord = true;
        if ([word compare:@"iPhone"] != 0 && [word compare:@"iPod"] != 0 && [word compare:@"iPad"] != 0 && [word length] > 2)
        {
            NSString *newWord = [word stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[word substringToIndex:1] uppercaseString]];
            [names addObject:newWord];
        }
    }
    if (!foundShortWord && [names count] > 1)
    {
        int lastNameIndex = [names count] - 1;
        NSString* name = [names objectAtIndex:lastNameIndex];
        unichar lastChar = [name characterAtIndex:[name length] - 1];
        if (lastChar == 's')
        {
            [names replaceObjectAtIndex:lastNameIndex withObject:[name substringToIndex:[name length] - 1]];
        }
    }
    return names;
}

NSArray * nameRegexFromDeviceName(NSString * deviceName)
{
    NSError * error;
    static NSString * expression = (@"^(?:iPhone|phone|iPad|iPod)\\s+(?:de\\s+)?|"
                                    "(\\S+?)(?:['’]?s)?(?:\\s+(?:iPhone|phone|iPad|iPod))?$|"
                                    "(\\S+?)(?:['’]?的)?(?:\\s*(?:iPhone|phone|iPad|iPod))?$|"
                                    "(\\S+)\\s+");
    static NSRange RangeNotFound = (NSRange){.location=NSNotFound, .length=0};
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                            options:(NSRegularExpressionCaseInsensitive)
                                                                              error:&error];
    NSMutableArray * name = [NSMutableArray new];
    for (NSTextCheckingResult * result in [regex matchesInString:deviceName
                                                         options:0
                                                           range:NSMakeRange(0, deviceName.length)]) {
        for (int i = 1; i < result.numberOfRanges; i++) {
            if (! NSEqualRanges([result rangeAtIndex:i], RangeNotFound)) {
                [name addObject:[deviceName substringWithRange:[result rangeAtIndex:i]].capitalizedString];
            }
        }
    }
    return name;
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
