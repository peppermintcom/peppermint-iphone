//
//  LoginTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol LoginTableViewCellDelegate <BaseTableViewCellDelegate>
-(void) selectedLoginTableViewCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath;
@end

@interface LoginTableViewCell : BaseTableViewCell

@property (weak, nonatomic) id<LoginTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *loginIconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginIconImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;


@end
