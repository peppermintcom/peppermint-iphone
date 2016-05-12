//
//  AddEmailForSMSContactView.h
//  Peppermint
//
//  Created by Okan Kurtulus on 09/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "BaseCustomView.h"
#import "PeppermintContact.h"

@protocol AddEmailForSMSContactViewDelegate <NSObject>
-(void) addEmailIsSuccessfullWithEmailContact:(PeppermintContact*) peppermintContact;
@end

@interface AddEmailForSMSContactView : BaseCustomView
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *emailValidImageView;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;

@property (weak, nonatomic) id<AddEmailForSMSContactViewDelegate> delegate;

+(instancetype) createInstanceWithDelegate:(id<AddEmailForSMSContactViewDelegate>) delegate;
-(void) presentOverView:(UIView*)view forPeppermintContact:(PeppermintContact*)peppermintContact;

@end
