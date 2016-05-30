//
//  ChatEntriesViewController.h
//  Peppermint
//
//  Created by Okan Kurtulus on 19/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseViewController.h"
#import "ChatEntryModel.h"
#import "HoldToRecordInfoView.h"

@class PeppermintContact;
@class RecordingGestureButton;
@class RecordingView;

@interface ChatEntriesViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, ChatEntryModelDelegate, ChatTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomInformationFullLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomInformationLabel;
@property (weak, nonatomic) IBOutlet UIView *microphoneView;
@property (weak, nonatomic) IBOutlet RecordingGestureButton *recordingButton;
@property (weak, nonatomic) IBOutlet HoldToRecordInfoView *holdToRecordView;
@property (weak, nonatomic) IBOutlet UIButton *cancelSendingButton;

@property (strong, nonatomic) ChatEntryModel *chatEntryModel;
@property (strong, nonatomic) RecordingView *recordingView;
@property (strong, nonatomic) PeppermintContact *peppermintContact;

@property (assign, nonatomic) ChatEntryType chatEntryTypesToShow;

-(void) refreshContent;

@end