//
//  MailContactTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 29/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

#define WIDTH_PADDING           5
#define WIDTH_REPLY_ICON        15
#define WIDTH_ALERTNEW_LABEL    30

@interface MailContactTableViewCell : BaseTableViewCell

@property(weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property(weak, nonatomic) IBOutlet UIView *cellSeperatorView;
@property (weak, nonatomic) IBOutlet UIView *informationView;
@property (weak, nonatomic) IBOutlet UIImageView *replyIconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyIconViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyIconViewRightPaddingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *alertNewMessageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertNewMessageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertNewMessageLabelRightPaddingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mailDateLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *mailSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *mailContentLabel;

#pragma mark - Set Avatar Image
-(void) setAvatarImage:(UIImage*) image;

@end
