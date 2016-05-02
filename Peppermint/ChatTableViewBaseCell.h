//
//  ChatTableViewBaseCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 24/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface ChatTableViewBaseCell : BaseTableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftDistanceConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerViewWidth;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UIView *messageView;

@property (assign, nonatomic) BOOL isSentByMe;
@property (weak, nonatomic) UITableView *tableView;
@end
