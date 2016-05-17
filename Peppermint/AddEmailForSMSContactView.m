//
//  AddEmailForSMSContactView.m
//  Peppermint
//
//  Created by Okan Kurtulus on 09/05/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "AddEmailForSMSContactView.h"
#import "CustomContactModel.h"

#define SIZE_BIG        17
#define SIZE_MIDDLE     15

@interface AddEmailForSMSContactView() <CustomContactModelDelegate, UITextFieldDelegate>
@end

@implementation AddEmailForSMSContactView {
    CustomContactModel *customContactModel;
    PeppermintContact *peppermintContactToModify;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.hidden = YES;
    customContactModel = [CustomContactModel new];
    customContactModel.delegate = self;
    peppermintContactToModify = nil;
    
    self.contentView.layer.cornerRadius = 15;
    self.contentView.backgroundColor = [UIColor peppermintGray248];

    [self initTitleText];
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(hide)];
    [self.backgroundView addGestureRecognizer:tapGesture];
    
    self.emailTextField.placeholder = LOC(@"Email", @"Email");
    self.emailTextField.delegate = self;
    [self.emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

-(void) initTitleText {
    NSMutableAttributedString *titleText = [NSMutableAttributedString new];
    [titleText addText:LOC(@"Sending via Email", @"title")
                ofSize:SIZE_BIG
               ofColor:[UIColor blackColor]
               andFont:[UIFont openSansBoldFontOfSize:SIZE_BIG]];
    
    [titleText addText:@"\n\n" ofSize:SIZE_BIG ofColor:[UIColor clearColor]];
    
    [titleText addText:LOC(@"No email address found. Please insert an email address for this contact.", @"information")
                ofSize:SIZE_MIDDLE
               ofColor:[UIColor blackColor]
               andFont:[UIFont openSansSemiBoldFontOfSize:SIZE_MIDDLE]];
    
    [titleText centerText];
    
    self.titleLabel.attributedText = titleText;
}

-(void) yesButtonActive {
    self.yesButton.backgroundColor      = [UIColor clearColor];
    self.yesButton.layer.borderColor    = [UIColor blackColor].CGColor;
    self.yesButton.tintColor = [UIColor warningColor];
    [self.yesButton setTitle:LOC(@"Save email address", @"Title") forState:UIControlStateNormal];
}

-(void) yesButtonInActive {
    self.yesButton.backgroundColor      = [UIColor clearColor];
    self.yesButton.layer.borderColor    = [UIColor blackColor].CGColor;
    self.yesButton.tintColor = [UIColor peppermintCancelOrange];
    [self.yesButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

-(void)textFieldDidChange :(UITextField *)textField {
    textField.text = textField.text.normalizeText;
    [self updateEmailValidImageView];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL result = NO;
    if([string isEqualToString:DONE_STRING]) {
        [self yesButtonPressed:self.yesButton];
    } else {
        result = YES;
    }
    return result;
}

-(void) updateEmailValidImageView {
    BOOL isEmailValid = [self.emailTextField.text isValidEmail];
    if(isEmailValid) {
        self.emailValidImageView.image = [UIImage imageNamed:@"email_active"];
        [self yesButtonActive];
        [self.emailTextField updateKeyboardReturnType:UIReturnKeyDone];
    } else {
        self.emailValidImageView.image = [UIImage imageNamed:@"email_inactive"];
        [self yesButtonInActive];
        [self.emailTextField updateKeyboardReturnType:UIReturnKeyDefault];
    }
}

+(instancetype) createInstanceWithDelegate:(id<AddEmailForSMSContactViewDelegate>) delegate {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddEmailForSMSContactView"
                                                             owner:self
                                                           options:nil];
    AddEmailForSMSContactView *addEmailForSMSContactView = (AddEmailForSMSContactView *)[topLevelObjects objectAtIndex:0];
    addEmailForSMSContactView.delegate = delegate;
    return addEmailForSMSContactView;
}

-(void) presentOverView:(UIView*)view forPeppermintContact:(PeppermintContact*)peppermintContact {
    peppermintContactToModify = peppermintContact;
    self.emailTextField.text = @"";
    [self showInView:view];
    [self updateEmailValidImageView];
    [self.emailTextField becomeFirstResponder];
}

-(void) showInView:(UIView*) view {
    UIView *superView = view.superview;
    if(self.superview != superView) {
        [superView addSubview:self];
    }
    [superView bringSubviewToFront:self];
    self.frame = view.frame;
    [self setNeedsDisplay];
    self.hidden = NO;
}

-(void) hide {
    [self.emailTextField resignFirstResponder];
    self.hidden = YES;
}

#pragma mark - Button Actions

-(IBAction)yesButtonPressed:(id)sender {
    NSLog(@"confirm:");
    NSString *email = self.emailTextField.text;
    [self performAddEmailOperationsWithEmail:email];
    [self hide];
}

-(void) performAddEmailOperationsWithEmail:(NSString*) email {
    if(!email.isValidEmail) {
        NSLog(@"Email:%@ is not valid", email);
    } else {
        peppermintContactToModify.communicationChannel = CommunicationChannelEmail;
        peppermintContactToModify.communicationChannelAddress = email;
        [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
        [customContactModel save:peppermintContactToModify];
    }
}

#pragma mark - CustomContactModelDelegate

-(void) customPeppermintContactSavedSucessfully:(PeppermintContact*) peppermintContact {
    [MBProgressHUD hideHUDForView:self.contentView animated:YES];
    [self hide];
    [self.delegate addEmailIsSuccessfullWithEmailContact:peppermintContact];
}

@end
