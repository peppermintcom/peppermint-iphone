//
//  ShowAllContactsTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 30/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol ShowAllContactsTableViewCellDelegate <BaseTableViewCellDelegate>
-(void) showAllContactsButtonPressed;
@end

@interface ShowAllContactsTableViewCell : BaseTableViewCell
@property (weak, nonatomic) id<ShowAllContactsTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
