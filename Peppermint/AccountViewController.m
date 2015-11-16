//
//  AccountViewController.m
//  Peppermint
//
//  Created by Okan Kurtulus on 12/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "AccountViewController.h"
#import "AppDelegate.h"
#import "LoginNavigationViewController.h"

#define NUMBER_OF_OPTIONS       3
#define OPTION_DISPLAY_NAME     0
#define OPTION_SIGNATURE        1
#define OPTION_LOG_OUT          2

@interface AccountViewController () <UIAlertViewDelegate, LoginNavigationViewControllerDelegate>

@end

@implementation AccountViewController

#pragma mark - PresentLoginModalView

+(instancetype) createInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:STORYBOARD_LOGIN bundle:[NSBundle mainBundle]];
    AccountViewController *accountViewController = [storyboard instantiateViewControllerWithIdentifier:VIEWCONTROLLER_ACCOUNT];
    return accountViewController;
}

+(void) presentAccountViewControllerWithCompletion:(void(^)(void))completion {
    UIViewController *rootVC = [AppDelegate Instance].window.rootViewController;
    PeppermintMessageSender *peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    
    if([peppermintMessageSender isValid]) {
        AccountViewController *accountViewController = [AccountViewController createInstance];
        accountViewController.iconCloseImageView.image = [UIImage imageNamed:@"icon_close"];
        [rootVC presentViewController:accountViewController animated:YES completion:completion];
    } else {
        [LoginNavigationViewController logUserInWithDelegate:nil completion:completion];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.iconCloseImageView.image = [UIImage imageNamed:@"icon_back"];
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:18];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.peppermintMessageSender = [PeppermintMessageSender sharedInstance];
    self.titleLabel.text = [NSString stringWithFormat:
                            LOC(@"Logged in message format", @"Logged in message format"),
                            [self.peppermintMessageSender loginMethod]
                            ];
    [self.titleLabel sizeToFit];    
    
    self.tableViewWidthConstraint.constant = self.view.frame.size.width / 2;
    [self.view setNeedsDisplay];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_OPTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginTableViewCell *logOutCell = [CellFactory cellLoginTableViewCellFromTable:tableView forIndexPath:indexPath withDelegate:self];
    
    NSInteger index = indexPath.section;
    if (index == OPTION_LOG_OUT) {
        logOutCell.loginIconImageViewWidthConstraint.constant = 0;
        logOutCell.loginIconImageView.image = nil;
        logOutCell.loginLabel.text = LOC(@"Log Out", @"Title");
        logOutCell.loginLabel.textColor = [UIColor googleLoginColor];
    } else if (index == OPTION_SIGNATURE) {
      logOutCell.loginIconImageViewWidthConstraint.constant = 0;
      logOutCell.loginIconImageView.image = nil;
      logOutCell.loginLabel.text = LOC(@"Subject", nil);
      logOutCell.loginLabel.textColor = [UIColor facebookLoginColor];
    } else if (index == OPTION_DISPLAY_NAME){
      logOutCell.loginIconImageViewWidthConstraint.constant = 0;
      logOutCell.loginIconImageView.image = nil;
      logOutCell.loginLabel.text = LOC(@"Display Name", nil);
      logOutCell.loginLabel.textColor = [UIColor emailLoginColor];
    }
    [logOutCell.loginLabel sizeToFit];
    return logOutCell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT_LOGIN_TABLEVIEWCELL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == OPTION_DISPLAY_NAME) {
    return 0;
  } else {
    return CELL_HEIGHT_LOGIN_TABLEVIEWCELL/2;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return [UIView new];
}

#pragma mark - LoginTableViewCellDelegate

-(void) selectedLoginTableViewCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath {
    NSInteger option = indexPath.section;

    if(option == OPTION_LOG_OUT) {
        [self.peppermintMessageSender clearSender];
        [self.navigationController popViewControllerAnimated:NO];
        [LoginNavigationViewController logUserInWithDelegate:nil completion:nil];
    } else if (option == OPTION_DISPLAY_NAME) {
      UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:LOC(@"Display Name", nil) message:LOC(@"Display Name Description", nil) delegate:self cancelButtonTitle:LOC(@"Cancel", nil) otherButtonTitles:LOC(@"Save", nil), nil];
      alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
      UITextField *textField = [alertView textFieldAtIndex:0];
      textField.text = self.peppermintMessageSender.nameSurname;
      [alertView show];
    } else {
      UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:LOC(@"Subject", nil) message:LOC(@"Subject Description", nil) delegate:self cancelButtonTitle:LOC(@"Cancel", nil) otherButtonTitles:LOC(@"Save", nil), nil];
      alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
      UITextField *textField = [alertView textFieldAtIndex:0];
      textField.text = self.peppermintMessageSender.subject;
      [alertView show];
    }
}

#pragma mark - CloseButton

-(IBAction)closeButtonPressed:(id)sender {
    if(!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark- UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == alertView.cancelButtonIndex) {
    return;
  }
  
  NSString * text = [[alertView textFieldAtIndex:0] text];

  if ([alertView.title isEqualToString:LOC(@"Display Name", nil)]) {
      if (text.length > 0) {
          self.peppermintMessageSender.nameSurname = text;
          [self.peppermintMessageSender save];
      } else {
          [[[UIAlertView alloc] initWithTitle:LOC(@"Error", nil) message:LOC(@"Display Name can not be empty", nil) delegate:nil cancelButtonTitle:LOC(@"Ok", nil) otherButtonTitles: nil] show];
      }
  } else if ([alertView.title isEqualToString:LOC(@"Subject", nil)]) {
      self.peppermintMessageSender.subject = text ? text : @"";
      [self.peppermintMessageSender save];
  }
}

#pragma mark - LoginNavigationViewControllerDelegate

- (void)loginSucceedWithMessageSender:(PeppermintMessageSender *)peppermintMessageSender {
  self.peppermintMessageSender = peppermintMessageSender;
  self.titleLabel.text = [NSString stringWithFormat:
                          LOC(@"Logged in message format", @"Logged in message format"),
                          [self.peppermintMessageSender loginMethod]
                          ];
}


@end
