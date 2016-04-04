//
//  FeedBackViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 05/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseRecordingViewController.h"

#import "FeedBackModel.h"
#import "FoggyRecordingView.h"

@interface FeedBackViewController : BaseRecordingViewController <UITableViewDataSource, UITableViewDelegate, FeedBackModelDelegate, ContactTableViewCellDelegate, RecordingViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *supportEmailLabel;

@property (strong, nonatomic) FeedBackModel *feedBackModel;

+(instancetype) createInstance;
@end
