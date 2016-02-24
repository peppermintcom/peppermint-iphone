//
//  AccountViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 12/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginModel.h"

@interface AccountViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, LoginTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconCloseImageView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewWidthConstraint;
@property (strong, nonatomic) PeppermintMessageSender *peppermintMessageSender;

+(instancetype) createInstance;
+(void) presentAccountViewControllerWithCompletion:(void(^)(void))completion;

@end
