//
//  ChatsViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 15/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ChatModel.h"

@interface ChatsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, ChatModelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+(instancetype) createInstance;

@end
