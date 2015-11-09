//
//  LoginValidateEmailTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 09/11/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol LoginValidateEmailTableViewCellDelegate <BaseTableViewCellDelegate>
-(void) resendValidation;
@end

@interface LoginValidateEmailTableViewCell : BaseTableViewCell

@property (weak, nonatomic) id<LoginValidateEmailTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonBorderView;
@property (weak, nonatomic) IBOutlet UILabel *buttonTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;


@end
