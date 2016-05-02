//
//  MailContactTableViewCell.m
//  Peppermint
//
//  Created by Okan Kurtulus on 29/04/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

#import "MailContactTableViewCell.h"

#define FONT_SIZE   13

@implementation MailContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cellSeperatorView.backgroundColor = [UIColor cellSeperatorGray];
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.layer.borderColor  = [UIColor whiteColor].CGColor;
    
    self.informationView.backgroundColor = [UIColor clearColor];
    self.replyIconView.image = [self.replyIconView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.replyIconView setTintColor:[UIColor textFieldTintGreen]];
    
    self.alertNewMessageLabel.layer.cornerRadius = 3;
    self.alertNewMessageLabel.textColor = [UIColor whiteColor];
    self.alertNewMessageLabel.font = [UIFont openSansFontOfSize:FONT_SIZE-4];
    self.alertNewMessageLabel.backgroundColor = [UIColor slideMenuTableViewCellTextLabelColor];
    self.alertNewMessageLabel.text = LOC(@"NEW", @"New Message Text");
    
    self.senderNameLabel.font = [UIFont openSansSemiBoldFontOfSize:FONT_SIZE];
    self.senderNameLabel.textColor = [UIColor textFieldTintGreen];
    
    self.mailDateLabel.font = [UIFont openSansSemiBoldFontOfSize:FONT_SIZE];
    self.mailDateLabel.textColor = [UIColor textFieldTintGreen];
    
    self.mailSubjectLabel.font = [UIFont openSansSemiBoldFontOfSize:FONT_SIZE];
    self.mailSubjectLabel.textColor = [UIColor blackColor];
    
    self.mailContentLabel.font = [UIFont openSansSemiBoldFontOfSize:FONT_SIZE];
    self.mailContentLabel.textColor = [UIColor textFieldTintGreen];
}

#pragma mark - Set Avatar Image

-(void) setAvatarImage:(UIImage*) image {
    if(image) {
        CGRect frame = self.avatarImageView.frame;
        int width = frame.size.width;
        int height = frame.size.height;
        self.avatarImageView.image = [image resizedImageWithWidth:width height:height];
    } else {
        self.avatarImageView.image = [UIImage imageNamed:@"avatar_empty"];
    }
}

@end
