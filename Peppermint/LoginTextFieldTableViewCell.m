//
//  LoginTextFieldTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginTextFieldTableViewCell.h"

#define TITLE_LABEL_WIDTH   60
#define DONE_STRING         @"\n"

@implementation LoginTextFieldTableViewCell {
    NSArray *titlesArray;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowRadius = 1;
    
    self.coverView.backgroundColor = [UIColor whiteColor];
    self.coverView.layer.cornerRadius = LOGIN_CORNER_RADIUS;
    
    self.textField.font = [UIFont openSansSemiBoldFontOfSize:16];
    self.textField.textColor = [UIColor blackColor];
    self.textField.tintColor = [UIColor textFieldTintGreen];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    
    titlesArray = nil;
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:16];
    self.titleLabel.textColor = [UIColor viaInformationLabelTextGreen];
    self.titleLabelWidthConstraint.constant = 0;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([string isEqualToString:DONE_STRING]) {
        [self.delegate doneButtonPressed];
    } else {
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decomposableCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
        
        if(self.disallowedCharsText.length == 0 || ![self.disallowedCharsText containsString:string])
        {
            [textField setTextContentInRange:range replacementString:string];
            [self.delegate updatedTextFor:self atIndexPath:self.indexPath];
        }
    }
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.textField.text = @"";
    [self.delegate updatedTextFor:self atIndexPath:self.indexPath];
    return NO;
}

-(IBAction)titleButtonPressed:(id)sender {
    NSUInteger index =  [titlesArray indexOfObject:self.titleLabel.text];
    NSUInteger nextIndex = ++index % titlesArray.count;
    self.titleLabel.text = [titlesArray objectAtIndex:nextIndex];
}

-(void) setTitles:(NSArray*) array {
    titlesArray = array;
    if(titlesArray.count > 0) {
        self.titleLabelWidthConstraint.constant = TITLE_LABEL_WIDTH;
        self.titleLabel.text = [titlesArray objectAtIndex:0];
    } else {
        self.titleLabelWidthConstraint.constant = 0;
    }
}

-(void) setValid:(BOOL) isValid {
    if(isValid) {
        self.coverView.layer.borderWidth = 0;
        self.textField.textColor = [UIColor blackColor];
    } else {
        self.coverView.layer.borderWidth = 3;
        self.coverView.layer.borderColor = [UIColor warningColor].CGColor;
        self.textField.textColor = [UIColor warningColor];
    }
}

@end