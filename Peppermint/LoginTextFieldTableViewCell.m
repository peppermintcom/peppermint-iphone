//
//  LoginTextFieldTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginTextFieldTableViewCell.h"

#define TITLE_LABEL_WIDTH   60

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
    self.textField.delegate = self;
    
    titlesArray = nil;
    self.titleLabel.font = [UIFont openSansSemiBoldFontOfSize:16];
    self.titleLabel.textColor = [UIColor viaInformationLabelTextGreen];
    self.titleLabelWidthConstraint.constant = 0;
}

#pragma mark - UITextFieldDelegate

- (void)selectTextForInput:(UITextField *)textField atRange:(NSRange)range {
    UITextPosition *start = [textField positionFromPosition:[textField beginningOfDocument]
                                                 offset:range.location];
    UITextPosition *end = [textField positionFromPosition:start
                                               offset:range.length];
    [textField setSelectedTextRange:[textField textRangeFromPosition:start toPosition:end]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(self.disallowedCharsText.length == 0
       || ![self.disallowedCharsText containsString:string]) {
        NSRange newRange = NSMakeRange(range.location + string.length, 0);
        NSString* text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.textField.text = text;
        [self selectTextForInput:textField atRange:newRange];
        [self.delegate updatedTextFor:self atIndexPath:self.indexPath];
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