//
//  ChatEntriesViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ChatEntriesModel.h"
#import "FoggyRecordingView.h"

@interface ChatEntriesViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, ChatEntriesModelDelegate, RecordingViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomInformationLabel;
@property (weak, nonatomic) IBOutlet UIView *microphoneView;
@property (weak, nonatomic) IBOutlet RecordingGestureButton *recordingButton;

@property (strong, nonatomic) ChatEntriesModel *chatEntriesModel;
@property (strong, nonatomic) RecordingView *recordingView;

@end