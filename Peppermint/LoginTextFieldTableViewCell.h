//
//  LoginTextFieldTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol LoginTextFieldTableViewCellDelegate <BaseTableViewCellDelegate>
-(void) updatedTextFor:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath;
@end

@interface LoginTextFieldTableViewCell : BaseTableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) id<LoginTextFieldTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end
