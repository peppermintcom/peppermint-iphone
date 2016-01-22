//
//  ChatEntriesViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ChatEntriesModel.h"

@interface ChatEntriesViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, ChatEntriesModelDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomInformationLabel;

@property (strong, nonatomic) ChatEntriesModel *chatEntriesModel;

@end