//
//  ChatTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 22/01/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"
@class PeppermintChatEntry;
@class PlayingModel;
@class ChatTableViewCell;

@protocol ChatTableViewCellDelegate <NSObject>
-(void) startedPlayingMessage:(ChatTableViewCell*)chatTableViewCell;
-(void) stoppedPlayingMessage:(ChatTableViewCell*)chatTableViewCell;
-(void) playMessageInCell:(ChatTableViewCell*)chatTableViewCell gotError:(NSError*)error;
@end

@interface ChatTableViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftDistanceConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerViewWidth;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UIImageView *playPauseImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@property (weak, nonatomic) IBOutlet UIView *timelineView;
@property (weak, nonatomic) IBOutlet UIView *durationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UIView *durationCircleView;

@property (weak, nonatomic) UITableView *tableView;

@property (weak, nonatomic) id<ChatTableViewCellDelegate> delegate;
@property (strong, nonatomic, readonly) PeppermintChatEntry *peppermintChatEntry;
@property (strong, nonatomic, readonly) PlayingModel *playingModel;



- (void) fillInformation:(PeppermintChatEntry*) chatEntry;
- (IBAction)playPauseButtonPressed:(id)sender;

-(void) setCancelButtonVisibilty:(BOOL)isCacnelAble;

@end
