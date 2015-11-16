//
//  SlideMenuViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 28/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ReSideMenuContainerViewController.h"

@interface SlideMenuViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, RESideMenuDelegate>
@property (weak, nonatomic) ReSideMenuContainerViewController *reSideMenuContainerViewController;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
