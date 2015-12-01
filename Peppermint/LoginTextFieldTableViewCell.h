//
//  LoginTextFieldTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

#warning "Clear all commented out code on header and method file. These codes are not deleted now cos the design can still change"

@protocol LoginTextFieldTableViewCellDelegate <BaseTableViewCellDelegate>
-(void) updatedTextFor:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath;
-(void) doneButtonPressed;
@end

@interface LoginTextFieldTableViewCell : BaseTableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) id<LoginTextFieldTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;

//Delete below code when you are cleaning warning!
//@property (strong, nonatomic) NSString* disallowedCharsText;
//Delete below code when you are cleaning warning!
//-(void) setTitles:(NSArray*) array;

-(void) setValid:(BOOL) isValid;

@end
