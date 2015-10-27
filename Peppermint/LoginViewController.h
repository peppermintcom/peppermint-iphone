//
//  LoginViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "PeppermintMessageSender.h"

@protocol LoginViewControllerDelegate <NSObject>
-(void) loginSucceedWithMessageSender:(PeppermintMessageSender*) peppermintMessageSender;
@end

@interface LoginViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, LoginTableViewCellDelegate>
@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

+(void) logUserInWithDelegate:(id<LoginViewControllerDelegate>) delegate;

@end
