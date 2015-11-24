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
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;
@property (strong, nonatomic) NSString* disallowedCharsText;

-(void) setTitles:(NSArray*) array;
-(void) setValid:(BOOL) isValid;

@end
