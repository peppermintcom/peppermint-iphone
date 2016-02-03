//
//  ChatTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"
@class ChatEntry;
@class PlayingModel;

@interface ChatTableViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftDistanceConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerViewWidth;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

@property (weak, nonatomic) IBOutlet UIImageView *playPauseImageView;
@property (weak, nonatomic) IBOutlet UIView *timelineView;
@property (weak, nonatomic) IBOutlet UIView *durationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UIView *durationCircleView;
@property(weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic, readonly) PlayingModel *playingModel;

- (void) fillInformation:(ChatEntry*) chatEntry;

@end
