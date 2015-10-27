//
//  LoginTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 26/10/15.
//  Copyright © 2015 Okan Kurtulus. All rights reserved.
//

#import "LoginTableViewCell.h"

@implementation LoginTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.loginLabel setFont:[UIFont openSansSemiBoldFontOfSize:17]];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 15;
}

-(IBAction)buttonTouched:(id)sender {
    self.alpha = 0.7;
}

-(IBAction)buttonReleasedOutside:(id)sender {
    self.alpha = 1;
}

-(IBAction)buttonReleasedInside:(id)sender {
    [self buttonReleasedOutside:sender];    
    [self.delegate selectedLoginTableViewCell:self atIndexPath:self.indexPath];
}


#warning "Remove if not used!"
-(void) setText:(NSString*) text withTitleImageNamed:(NSString*) imageName {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:imageName];
    attachment.bounds = CGRectMake(0, 0, 10, 10);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *attributedLoginText= [[NSMutableAttributedString alloc] initWithString:text];
    
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    
    [s appendAttributedString:attributedLoginText];
    

    //[attributedLoginText appendAttributedString:attachmentString];
    
    
    
    self.loginLabel.attributedText = s;
}

@end
