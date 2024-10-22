//
//  LoginTextFieldTableViewCell.h
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol LoginTextFieldTableViewCellDelegate <BaseTableViewCellDelegate>
-(void) textFieldDidBeginEdiging:(UITextField*)textField;
-(void) updatedTextFor:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath;
-(void) doneButtonPressed;
@end

@interface LoginTextFieldTableViewCell : BaseTableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) id<LoginTextFieldTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSArray *notAllowedCharactersArray;

-(void) setValid:(BOOL) isValid;

@end
