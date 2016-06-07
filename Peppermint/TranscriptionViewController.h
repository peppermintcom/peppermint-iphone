//
//  TranscriptionViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 07/06/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "TranscriptionModel.h"

@interface TranscriptionViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, SearchMenuTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) TranscriptionModel *transcriptionModel;

+(instancetype) createInstance;

@end
